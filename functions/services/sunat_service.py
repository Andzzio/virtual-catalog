"""
Servicio para integración con SUNAT directo vía sunat-py SDK.
Maneja:
- Carga y validación de certificados digitales
- Emisión de comprobantes (Factura, Boleta)
- Comunicación con SUNAT via SOAP
"""
import base64
import json
from datetime import datetime
from typing import Dict, Any, Optional
from decimal import Decimal
from cryptography.hazmat.primitives.serialization import pkcs12
from cryptography.hazmat.backends import default_backend

from sunat_py import (
    InvoiceInput, CreditNoteInput, DebitNoteInput, InvoiceLine, Party, ReferenciaDoc,
    build_invoice_xml, build_creditnote_xml, build_debitnote_xml,
    compute_totals, monto_en_letras,
    load_cert_from_base64, sign_invoice_xml,
    pack_invoice, build_zeep_client, send_bill, SunatError
)
from sunat_py.catalogs import credit_reason, debit_reason
from google.cloud import secretmanager


class SunatCertificateManager:
    """Maneja certificados digitales en Google Cloud Secret Manager"""

    def __init__(self, project_id: str):
        self.project_id = project_id
        self.client = secretmanager.SecretManagerServiceClient()

    def store_certificate(
        self,
        ruc: str,
        pfx_base64: str,
        password: str,
        environment: str = "beta"
    ) -> Dict[str, Any]:
        """
        Valida y almacena un certificado en Secret Manager.
        
        Args:
            ruc: RUC del negocio (ej: "20XXXXXXXXX")
            pfx_base64: Certificado .pfx codificado en base64
            password: Contraseña del .pfx
            environment: "beta" o "prod"
            
        Returns:
            {
                "success": bool,
                "expiresAt": datetime,
                "commonName": str,
                "error": str (si aplica)
            }
        """
        try:
            # 1. Validar y decodificar el .pfx
            pfx_bytes = base64.b64decode(pfx_base64)
            cert_bundle = load_cert_from_base64(pfx_base64, password)

            # 2. Extraer fecha de expiración
            cert_obj = cert_bundle.certificate
            expires_at = cert_obj.not_valid_after
            common_name = cert_bundle.common_name

            # 3. Guardar en Secret Manager
            secret_id = f"cert-{ruc}-{environment}"
            self._create_or_update_secret(secret_id, pfx_base64)

            return {
                "success": True,
                "expiresAt": expires_at.isoformat(),
                "commonName": common_name,
                "secretId": secret_id,
            }
        except ValueError as e:
            return {
                "success": False,
                "error": f"Certificado inválido: {str(e)}"
            }
        except Exception as e:
            return {
                "success": False,
                "error": f"Error al procesar certificado: {str(e)}"
            }

    def get_certificate(self, ruc: str, environment: str = "beta") -> Optional[str]:
        """
        Obtiene un certificado desde Secret Manager.
        
        Args:
            ruc: RUC del negocio
            environment: "beta" o "prod"
            
        Returns:
            .pfx codificado en base64, o None si no existe
        """
        try:
            secret_id = f"cert-{ruc}-{environment}"
            secret_name = f"projects/{self.project_id}/secrets/{secret_id}/versions/latest"
            response = self.client.access_secret_version(request={"name": secret_name})
            return response.payload.data.decode("UTF-8")
        except Exception:
            return None

    def _create_or_update_secret(self, secret_id: str, secret_value: str):
        """Crea o actualiza un secreto en Secret Manager"""
        parent = f"projects/{self.project_id}"

        try:
            # Intenta acceder al secreto existente
            secret_name = f"{parent}/secrets/{secret_id}"
            self.client.get_secret(request={"name": secret_name})
            # Si existe, agregar una nueva versión
            self.client.add_secret_version(
                request={
                    "parent": secret_name,
                    "payload": {"data": secret_value.encode("UTF-8")}
                }
            )
        except:
            # Si no existe, crear uno nuevo
            self.client.create_secret(
                request={
                    "parent": parent,
                    "secret_id": secret_id,
                    "secret": {
                        "replication": {
                            "automatic": {}
                        }
                    }
                }
            )
            secret_name = f"{parent}/secrets/{secret_id}"
            self.client.add_secret_version(
                request={
                    "parent": secret_name,
                    "payload": {"data": secret_value.encode("UTF-8")}
                }
            )


class SunatEmitter:
    """Maneja la emisión de comprobantes a SUNAT"""

    def __init__(self, cert_manager: SunatCertificateManager, project_id: str):
        self.cert_manager = cert_manager
        self.project_id = project_id

    def emit_invoice(
        self,
        ruc: str,
        sunat_user: str,
        sunat_password: str,
        invoice_data: Dict[str, Any],
        certificate_password: str,
        environment: str = "beta"
    ) -> Dict[str, Any]:
        """
        Emite una factura o boleta a SUNAT.
        
        Args:
            ruc: RUC del negocio emisor
            sunat_user: Usuario SOL
            sunat_password: Contraseña SOL
            invoice_data: Datos de la factura
                {
                    "tipo_documento": "01" (factura) o "03" (boleta),
                    "serie": "F001",
                    "numero": 1,
                    "fecha_emision": "2026-05-08",
                    "moneda": "PEN",
                    "receptor": {
                        "tipo_doc": "6",
                        "numero_doc": "20512345678",
                        "razon_social": "Cliente SAC",
                        "direccion": "Dirección"
                    },
                    "lines": [
                        {
                            "codigo": "P001",
                            "descripcion": "Producto",
                            "unidad": "ZZ",
                            "cantidad": "1.00",
                            "precio_unitario": "100.00",
                            "igv_afectacion": "10"
                        }
                    ]
                }
            certificate_password: Contraseña del .pfx
            environment: "beta" o "prod"
            
        Returns:
            {
                "success": bool,
                "status": "accepted" | "rejected",
                "hash": str,
                "code": str,
                "description": str,
                "cdrUrl": str (opcional),
                "error": str (si aplica)
            }
        """
        try:
            # 1. Obtener certificado
            pfx_base64 = self.cert_manager.get_certificate(ruc, environment)
            if not pfx_base64:
                return {
                    "success": False,
                    "error": "Certificado no encontrado. Verifica que lo hayas cargado en Ajustes."
                }

            # 2. Construir comprobante UBL
            receptor = invoice_data["receptor"]
            lines = invoice_data["lines"]

            # Construir líneas
            invoice_lines = []
            for line in lines:
                igv_amount = (
                    float(line["precio_unitario"]) *
                    float(line["cantidad"]) *
                    (float(line["igv_afectacion"]) / 100)
                )
                invoice_lines.append(
                    InvoiceLine(
                        codigo=line["codigo"],
                        descripcion=line["descripcion"],
                        unidad=line["unidad"],
                        cantidad=Decimal(str(line["cantidad"])),
                        precio_unitario=Decimal(str(line["precio_unitario"])),
                        igv_afectacion=line["igv_afectacion"],
                    )
                )

            # Calcular totales
            totals = compute_totals(invoice_lines)
            razon_social_emisor = "TU EMPRESA SAC"  # TODO: traer de Firestore Business
            direccion_emisor = "DIRECCIÓN"  # TODO: traer de Firestore Business

            ubl_input = InvoiceInput(
                tipo_documento=invoice_data["tipo_documento"],
                serie=invoice_data["serie"],
                numero=invoice_data["numero"],
                fecha_emision=datetime.strptime(
                    invoice_data["fecha_emision"], "%Y-%m-%d"
                ).date(),
                moneda=invoice_data["moneda"],
                emisor=Party(
                    tipo_doc="6",
                    numero_doc=ruc,
                    razon_social=razon_social_emisor,
                    direccion=direccion_emisor,
                ),
                receptor=Party(
                    tipo_doc=receptor["tipo_doc"],
                    numero_doc=receptor["numero_doc"],
                    razon_social=receptor["razon_social"],
                    direccion=receptor.get("direccion", ""),
                ),
                lines=invoice_lines,
            )

            # 3. Generar XML sin firmar
            xml = build_invoice_xml(ubl_input)

            # 4. Firmar XML
            cert_bundle = load_cert_from_base64(pfx_base64, certificate_password)
            signed_xml = sign_invoice_xml(xml, cert_bundle)

            # 5. Empaquetar en ZIP
            filename = f"{ruc}-{invoice_data['tipo_documento']}-{invoice_data['serie']}-{invoice_data['numero']}"
            zip_bytes = pack_invoice(signed_xml, filename)

            # 6. Enviar a SUNAT
            sunat_client = build_zeep_client(
                mode=environment,
                ruc=ruc,
                username=sunat_user,
                password=sunat_password,
                timeout=120,
            )
            result = send_bill(sunat_client, zip_bytes, f"{filename}.zip")

            return {
                "success": True,
                "status": result.status,
                "code": result.code,
                "description": result.description,
                "hash": getattr(result, 'hash', None),
                "cdrUrl": getattr(result, 'cdrUrl', None),
            }

        except SunatError as e:
            return {
                "success": False,
                "error": f"Error SUNAT ({e.code}): {e.message}"
            }
        except Exception as e:
            return {
                "success": False,
                "error": f"Error al emitir comprobante: {str(e)}"
            }

    def emit_credit_note(
        self,
        ruc: str,
        sunat_user: str,
        sunat_password: str,
        note_data: Dict[str, Any],
        certificate_password: str,
        environment: str = "beta"
    ) -> Dict[str, Any]:
        """
        Emite una Nota de Crédito (07) a SUNAT.

        note_data debe incluir:
            "tipo_documento": "07",
            "serie": "FC01" o "BC01",
            "numero": int,
            "fecha_emision": "2026-05-08",
            "moneda": "PEN",
            "motivo_codigo": "01".."13" (catálogo 09),
            "motivo_descripcion": str,
            "referencia": {"tipo_doc": "01"|"03", "serie": "F001", "numero": 1},
            "receptor": {...},
            "lines": [...]
        """
        try:
            pfx_base64 = self.cert_manager.get_certificate(ruc, environment)
            if not pfx_base64:
                return {"success": False, "error": "Certificado no encontrado. Verifica que lo hayas cargado en Ajustes."}

            receptor = note_data["receptor"]
            lines = note_data["lines"]
            ref = note_data["referencia"]

            invoice_lines = []
            for line in lines:
                invoice_lines.append(InvoiceLine(
                    codigo=line["codigo"],
                    descripcion=line["descripcion"],
                    unidad=line["unidad"],
                    cantidad=Decimal(str(line["cantidad"])),
                    precio_unitario=Decimal(str(line["precio_unitario"])),
                    igv_afectacion=line["igv_afectacion"],
                ))

            razon_social_emisor = note_data.get("razon_social_emisor", "TU EMPRESA SAC")
            direccion_emisor = note_data.get("direccion_emisor", "DIRECCIÓN")

            ubl_input = CreditNoteInput(
                serie=note_data["serie"],
                numero=note_data["numero"],
                fecha_emision=datetime.strptime(note_data["fecha_emision"], "%Y-%m-%d").date(),
                moneda=note_data["moneda"],
                motivo_codigo=note_data["motivo_codigo"],
                motivo_descripcion=note_data["motivo_descripcion"],
                referencia=ReferenciaDoc(
                    tipo_doc=ref["tipo_doc"],
                    serie=ref["serie"],
                    numero=ref["numero"],
                ),
                emisor=Party(
                    tipo_doc="6", numero_doc=ruc,
                    razon_social=razon_social_emisor, direccion=direccion_emisor,
                ),
                receptor=Party(
                    tipo_doc=receptor["tipo_doc"],
                    numero_doc=receptor["numero_doc"],
                    razon_social=receptor["razon_social"],
                    direccion=receptor.get("direccion", ""),
                ),
                lines=invoice_lines,
            )

            xml = build_creditnote_xml(ubl_input)
            cert_bundle = load_cert_from_base64(pfx_base64, certificate_password)
            signed_xml = sign_invoice_xml(xml, cert_bundle)

            filename = f"{ruc}-07-{note_data['serie']}-{note_data['numero']}"
            zip_bytes = pack_invoice(signed_xml, filename)

            sunat_client = build_zeep_client(
                mode=environment, ruc=ruc,
                username=sunat_user, password=sunat_password, timeout=120,
            )
            result = send_bill(sunat_client, zip_bytes, f"{filename}.zip")

            return {
                "success": True,
                "status": result.status,
                "code": result.code,
                "description": result.description,
                "hash": getattr(result, 'hash', None),
                "cdrUrl": getattr(result, 'cdrUrl', None),
            }

        except SunatError as e:
            return {"success": False, "error": f"Error SUNAT ({e.code}): {e.message}"}
        except Exception as e:
            return {"success": False, "error": f"Error al emitir Nota de Crédito: {str(e)}"}

    def emit_debit_note(
        self,
        ruc: str,
        sunat_user: str,
        sunat_password: str,
        note_data: Dict[str, Any],
        certificate_password: str,
        environment: str = "beta"
    ) -> Dict[str, Any]:
        """
        Emite una Nota de Débito (08) a SUNAT.

        note_data debe incluir:
            "tipo_documento": "08",
            "serie": "FD01" o "BD01",
            "numero": int,
            "fecha_emision": "2026-05-08",
            "moneda": "PEN",
            "motivo_codigo": "01".."03" (catálogo 10),
            "motivo_descripcion": str,
            "referencia": {"tipo_doc": "01"|"03", "serie": "F001", "numero": 1},
            "receptor": {...},
            "lines": [...]
        """
        try:
            pfx_base64 = self.cert_manager.get_certificate(ruc, environment)
            if not pfx_base64:
                return {"success": False, "error": "Certificado no encontrado. Verifica que lo hayas cargado en Ajustes."}

            receptor = note_data["receptor"]
            lines = note_data["lines"]
            ref = note_data["referencia"]

            invoice_lines = []
            for line in lines:
                invoice_lines.append(InvoiceLine(
                    codigo=line["codigo"],
                    descripcion=line["descripcion"],
                    unidad=line["unidad"],
                    cantidad=Decimal(str(line["cantidad"])),
                    precio_unitario=Decimal(str(line["precio_unitario"])),
                    igv_afectacion=line["igv_afectacion"],
                ))

            razon_social_emisor = note_data.get("razon_social_emisor", "TU EMPRESA SAC")
            direccion_emisor = note_data.get("direccion_emisor", "DIRECCIÓN")

            ubl_input = DebitNoteInput(
                serie=note_data["serie"],
                numero=note_data["numero"],
                fecha_emision=datetime.strptime(note_data["fecha_emision"], "%Y-%m-%d").date(),
                moneda=note_data["moneda"],
                motivo_codigo=note_data["motivo_codigo"],
                motivo_descripcion=note_data["motivo_descripcion"],
                referencia=ReferenciaDoc(
                    tipo_doc=ref["tipo_doc"],
                    serie=ref["serie"],
                    numero=ref["numero"],
                ),
                emisor=Party(
                    tipo_doc="6", numero_doc=ruc,
                    razon_social=razon_social_emisor, direccion=direccion_emisor,
                ),
                receptor=Party(
                    tipo_doc=receptor["tipo_doc"],
                    numero_doc=receptor["numero_doc"],
                    razon_social=receptor["razon_social"],
                    direccion=receptor.get("direccion", ""),
                ),
                lines=invoice_lines,
            )

            xml = build_debitnote_xml(ubl_input)
            cert_bundle = load_cert_from_base64(pfx_base64, certificate_password)
            signed_xml = sign_invoice_xml(xml, cert_bundle)

            filename = f"{ruc}-08-{note_data['serie']}-{note_data['numero']}"
            zip_bytes = pack_invoice(signed_xml, filename)

            sunat_client = build_zeep_client(
                mode=environment, ruc=ruc,
                username=sunat_user, password=sunat_password, timeout=120,
            )
            result = send_bill(sunat_client, zip_bytes, f"{filename}.zip")

            return {
                "success": True,
                "status": result.status,
                "code": result.code,
                "description": result.description,
                "hash": getattr(result, 'hash', None),
                "cdrUrl": getattr(result, 'cdrUrl', None),
            }

        except SunatError as e:
            return {"success": False, "error": f"Error SUNAT ({e.code}): {e.message}"}
        except Exception as e:
            return {"success": False, "error": f"Error al emitir Nota de Débito: {str(e)}"}
