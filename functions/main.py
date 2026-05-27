# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`
import base64
import requests
from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app
import json
from firebase_functions import https_fn, options
from firebase_functions.options import set_global_options
import os

from data.business_repository import get_business_credentials
from services.izipay_service import create_payment_form_url
from presentation.templates.izipay_checkout import get_checkout_html
from services.ipn_service import process_ipn_webhook
from services.sunat_service import SunatCertificateManager, SunatEmitter

set_global_options(max_instances=10)

# Instancias lazy para evitar timeout en cold start
PROJECT_ID = os.getenv("GCLOUD_PROJECT", "catalogo-virtual-app")
_cert_manager = None
_sunat_emitter = None


def _get_cert_manager() -> SunatCertificateManager:
    global _cert_manager
    if _cert_manager is None:
        _cert_manager = SunatCertificateManager(PROJECT_ID)
    return _cert_manager


def _get_sunat_emitter() -> SunatEmitter:
    global _sunat_emitter
    if _sunat_emitter is None:
        _sunat_emitter = SunatEmitter(_get_cert_manager(), PROJECT_ID)
    return _sunat_emitter

@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]))
def create_izipay_payment(req: https_fn.Request) -> https_fn.Response:
    try:
        body = req.get_json()
        if not body:
            return https_fn.Response(json.dumps({"error": "No data"}), status=400, content_type="application/json")

        amount = body.get("amount")
        order_id = body.get("orderId")
        business_id = body.get("businessId")
        customer_email = body.get("customerEmail", "comprador@email.com")
        customer_name = body.get("customerName", "")
        customer_last_name = body.get("customerLastName", "")
        
        if not amount or not order_id or not business_id:
            return https_fn.Response(json.dumps({"error": "Faltan parámetros: amount, orderId o businessId"}), status=400, content_type="application/json")

        try:
            creds = get_business_credentials(business_id)
        except ValueError as e:
            return https_fn.Response(json.dumps({"error": str(e)}), status=400, content_type="application/json")
            
        try:
            payment_url = create_payment_form_url(amount, order_id, creds, customer_email, customer_name, customer_last_name)
            return https_fn.Response(json.dumps({
                "success": True,
                "paymentUrl": payment_url
            }), status=200, content_type="application/json")
        except Exception as e:
             return https_fn.Response(json.dumps({"success": False, "error": str(e)}), status=400, content_type="application/json")

    except Exception as e:
        return https_fn.Response(json.dumps({"error": str(e)}), status=500, content_type="application/json")

@https_fn.on_request()
def render_izipay_checkout(req: https_fn.Request) -> https_fn.Response:
    form_token = str(req.args.get("token", "")).strip()
    public_key = str(req.args.get("publicKey", "")).strip()
    amount = str(req.args.get("amount", "")).strip()
    
    if not form_token or not public_key:
        return https_fn.Response("Faltan datos de pago", status=400)
        
    html = get_checkout_html(form_token, public_key, amount)
    return https_fn.Response(html, status=200, content_type="text/html; charset=utf-8")

@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["post"]))
def izipay_webhook(req: https_fn.Request) -> https_fn.Response:
    try:
        form_data = req.form.to_dict() if req.form else {}
        if not form_data and req.is_json:
            form_data = req.get_json() or {}
            
        if not form_data:
            return https_fn.Response("No payload", status=400)
            
        # DEBUG: Ver qué nos manda Izipay
        print(f"DEBUG: Webhook recibido. Data: {list(form_data.keys())}")
        if "kr-answer" in form_data:
             print(f"DEBUG: kr-answer: {form_data['kr-answer']}")
            
        result = process_ipn_webhook(form_data)
        return https_fn.Response(result, status=200, content_type="text/plain")
    except ValueError as e:
        print(f"Error de IPN: {e}")
        return https_fn.Response(str(e), status=400, content_type="text/plain")
    except Exception as e:
        print(f"Error inesperado en IPN: {e}")
        return https_fn.Response("Error interno", status=500, content_type="text/plain")


# ============================================================================
# FUNCIONES SUNAT - Facturación Electrónica Directa
# ============================================================================

@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["post"]))
def upload_certificate(req: https_fn.Request) -> https_fn.Response:
    """
    Sube un certificado digital (.pfx) a Secret Manager.
    
    Body esperado:
    {
        "ruc": "20XXXXXXXXX",
        "pfxBase64": "MIIFa...[archivo encriptado en base64]...gKBg",
        "password": "contraseña_del_pfx",
        "environment": "beta" | "prod"
    }
    
    Respuesta:
    {
        "success": true,
        "expiresAt": "2028-06-15T10:30:00",
        "commonName": "CN...",
        "error": "..." (si aplica)
    }
    """
    try:
        body = req.get_json()
        if not body:
            return https_fn.Response(
                json.dumps({"error": "No data"}),
                status=400,
                content_type="application/json"
            )

        ruc = body.get("ruc")
        pfx_base64 = body.get("pfxBase64")
        password = body.get("password")
        environment = body.get("environment", "beta")

        if not ruc or not pfx_base64 or not password:
            return https_fn.Response(
                json.dumps({"error": "Faltan parámetros: ruc, pfxBase64, password"}),
                status=400,
                content_type="application/json"
            )

        # Validar y almacenar certificado
        result = _get_cert_manager().store_certificate(ruc, pfx_base64, password, environment)

        status_code = 200 if result.get("success") else 400
        return https_fn.Response(
            json.dumps(result),
            status=status_code,
            content_type="application/json"
        )

    except Exception as e:
        print(f"Error en upload_certificate: {e}")
        return https_fn.Response(
            json.dumps({"error": str(e)}),
            status=500,
            content_type="application/json"
        )


@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["post"]))
def emit_to_sunat(req: https_fn.Request) -> https_fn.Response:
    """
    Emite una factura o boleta directamente a SUNAT.
    
    Body esperado:
    {
        "businessId": "mi-negocio-123",
        "invoiceData": {
            "tipo_documento": "01" | "03",
            "serie": "F001" | "B001",
            "numero": 1,
            "fecha_emision": "2026-05-08",
            "moneda": "PEN",
            "receptor": {
                "tipo_doc": "6" | "1",
                "numero_doc": "20512345678",
                "razon_social": "Cliente SAC",
                "direccion": "Dirección del cliente"
            },
            "lines": [
                {
                    "codigo": "P001",
                    "descripcion": "Producto/Servicio",
                    "unidad": "ZZ",
                    "cantidad": "1.00",
                    "precio_unitario": "100.00",
                    "igv_afectacion": "10"
                }
            ]
        },
        "certificatePassword": "contraseña_del_pfx"
    }
    
    Respuesta:
    {
        "success": true,
        "status": "accepted" | "rejected",
        "code": "0",
        "description": "La Factura ha sido aceptada",
        "hash": "código_qr",
        "error": "..." (si aplica)
    }
    """
    try:
        from firebase_admin import firestore
        
        body = req.get_json()
        if not body:
            return https_fn.Response(
                json.dumps({"error": "No data"}),
                status=400,
                content_type="application/json"
            )

        business_id = body.get("businessId")
        invoice_data = body.get("invoiceData")
        cert_password = body.get("certificatePassword")

        if not business_id or not invoice_data or not cert_password:
            return https_fn.Response(
                json.dumps({"error": "Faltan parámetros: businessId, invoiceData, certificatePassword"}),
                status=400,
                content_type="application/json"
            )

        # 1. Obtener datos del negocio desde Firestore
        db = firestore.client()
        business_doc = db.collection("businesses").document(business_id).get()

        if not business_doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Negocio no encontrado"}),
                status=404,
                content_type="application/json"
            )

        business = business_doc.to_dict()
        ruc = business.get("ruc")
        sunat_user = business.get("sunatUser")
        sunat_password = business.get("sunatPassword")
        environment = business.get("sunatEnvironment", "beta")

        if not ruc or not sunat_user or not sunat_password:
            return https_fn.Response(
                json.dumps({"error": "Negocio sin credenciales SUNAT configuradas"}),
                status=400,
                content_type="application/json"
            )

        # 2. Emitir comprobante
        tipo_doc = invoice_data.get("tipo_documento", "01")
        emitter = _get_sunat_emitter()

        if tipo_doc in ("07",):
            result = emitter.emit_credit_note(
                ruc=ruc, sunat_user=sunat_user, sunat_password=sunat_password,
                note_data=invoice_data, certificate_password=cert_password,
                environment=environment,
            )
        elif tipo_doc in ("08",):
            result = emitter.emit_debit_note(
                ruc=ruc, sunat_user=sunat_user, sunat_password=sunat_password,
                note_data=invoice_data, certificate_password=cert_password,
                environment=environment,
            )
        else:
            result = emitter.emit_invoice(
                ruc=ruc, sunat_user=sunat_user, sunat_password=sunat_password,
                invoice_data=invoice_data, certificate_password=cert_password,
                environment=environment,
            )

        status_code = 200 if result.get("success") else 400
        return https_fn.Response(
            json.dumps(result),
            status=status_code,
            content_type="application/json"
        )

    except Exception as e:
        print(f"Error en emit_to_sunat: {e}")
        return https_fn.Response(
            json.dumps({"error": str(e)}),
            status=500,
            content_type="application/json"
        )


# ============================================================================
# FIN FUNCIONES SUNAT
# ============================================================================


@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["post"]))
def register_user(req: https_fn.Request) -> https_fn.Response:
    try:
        from firebase_admin import auth, firestore
        body = req.get_json()
        if not body:
            return https_fn.Response(json.dumps({"error": "No data"}), status=400, content_type="application/json")
        email = body.get("email")
        password = body.get("password")
        name = body.get("name")
        role = body.get("role", "vendedor")
        business_id = body.get("businessId")
        if not email or not password or not name or not business_id:
            return https_fn.Response(json.dumps({"error": "Missing parameters"}), status=400, content_type="application/json")
        user_record = auth.create_user(
            email=email,
            password=password,
            display_name=name
        )
        uid = user_record.uid
        db = firestore.client()
        db.collection("users").document(uid).set({
            "id": uid,
            "email": email,
            "name": name,
            "role": role,
            "businessId": business_id,
            "createdAt": firestore.SERVER_TIMESTAMP
        })
        return https_fn.Response(json.dumps({"success": True, "uid": uid}), status=200, content_type="application/json")
    except Exception as e:
        return https_fn.Response(json.dumps({"error": str(e)}), status=500, content_type="application/json")

@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["post"]))
def delete_user(req: https_fn.Request) -> https_fn.Response:
    try:
        from firebase_admin import auth, firestore
        body = req.get_json()
        if not body:
            return https_fn.Response(json.dumps({"error": "No data"}), status=400, content_type="application/json")
        user_id = body.get("userId")
        if not user_id:
            return https_fn.Response(json.dumps({"error": "Missing userId"}), status=400, content_type="application/json")
        try:
            auth.delete_user(user_id)
        except Exception:
            pass
        db = firestore.client()
        db.collection("users").document(user_id).delete()
        return https_fn.Response(json.dumps({"success": True}), status=200, content_type="application/json")
    except Exception as e:
        return https_fn.Response(json.dumps({"error": str(e)}), status=500, content_type="application/json")

@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["post"]))
def update_user_role(req: https_fn.Request) -> https_fn.Response:
    try:
        from firebase_admin import firestore
        body = req.get_json()
        if not body:
            return https_fn.Response(json.dumps({"error": "No data"}), status=400, content_type="application/json")
        user_id = body.get("userId")
        role = body.get("role")
        if not user_id or not role:
            return https_fn.Response(json.dumps({"error": "Missing parameters"}), status=400, content_type="application/json")
        db = firestore.client()
        db.collection("users").document(user_id).update({
            "role": role
        })
        return https_fn.Response(json.dumps({"success": True}), status=200, content_type="application/json")
    except Exception as e:
        return https_fn.Response(json.dumps({"error": str(e)}), status=500, content_type="application/json")