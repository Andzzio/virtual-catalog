import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:virtual_catalog_app/data/services/nubefact_service.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/domain/entities/sale_item.dart';
import 'package:virtual_catalog_app/domain/repos/stock_movement_repository.dart';
import 'package:virtual_catalog_app/domain/usecases/create_sale.dart';
import 'package:virtual_catalog_app/domain/usecases/get_sales.dart';
import 'package:virtual_catalog_app/domain/usecases/update_sale_sunat_status.dart';

class SalesProvider extends ChangeNotifier {
  final GetSales getSalesUseCase;
  final CreateSale createSaleUseCase;
  final UpdateSaleSunatStatus updateSaleSunatStatusUseCase;
  final StockMovementRepository stockMovementRepository;
  final NubefactService _nubefactService = NubefactService();

  SalesProvider({
    required this.getSalesUseCase,
    required this.createSaleUseCase,
    required this.updateSaleSunatStatusUseCase,
    required this.stockMovementRepository,
  });

  List<Sale> sales = [];
  bool isLoading = false;

  Future<void> loadSales(String businessSlug) async {
    isLoading = true;
    notifyListeners();
    try {
      sales = await getSalesUseCase(businessSlug);
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<void> emitSale({
    required String businessSlug,
    required String customerName,
    required String customerDoc,
    required String customerAddress,
    required String customerPhone,
    required String documentType,
    required String paymentMethod,
    required List<SaleItem> items,
    required String notes,
    required String userId,
    required String userName,
    required List<Product> currentProducts,
    required Future<void> Function(Product) onUpdateProduct,
    Business? business,
    String? motivoCodigo,
    String? motivoDescripcion,
    String? refDocSerie,
    int? refDocNumero,
    String? refDocType,
  }) async {
    if (items.isEmpty) throw Exception("La venta requiere al menos un item");
    if (documentType == 'factura' && customerDoc.trim().length != 11) {
      throw Exception("Factura requiere RUC válido (11 dígitos)");
    }

    final total = items.fold<double>(0.0, (acc, item) => acc + item.lineTotal);
    final double igv;
    final double subtotal;

    if (documentType == 'nota_venta') {
      igv = 0.0;
      subtotal = total;
    } else {
      igv = double.parse((total - (total / 1.18)).toStringAsFixed(2));
      subtotal = double.parse((total - igv).toStringAsFixed(2));
    }

    final initialSale = Sale(
      id: '',
      number: '',
      documentType: documentType,
      customerName: customerName.trim(),
      customerDoc: customerDoc.trim(),
      customerAddress: customerAddress.trim(),
      customerPhone: customerPhone.trim(),
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      igv: igv,
      total: total,
      notes: notes.trim(),
      userId: userId,
      userName: userName,
      createdAt: DateTime.now(),
      items: items,
      sunatStatus: documentType == 'nota_venta' ? null : 'pending',
      motivoCodigo: motivoCodigo,
      motivoDescripcion: motivoDescripcion,
      refDocSerie: refDocSerie,
      refDocNumero: refDocNumero,
    );

    final savedSale = await createSaleUseCase(businessSlug, initialSale);

    if (documentType != 'nota_venta') {
      final hasNubefact = business != null &&
          business.nubefactUrl != null &&
          business.nubefactUrl!.isNotEmpty &&
          business.nubefactToken != null &&
          business.nubefactToken!.isNotEmpty;

      final hasSunatDirect = business != null &&
          business.hasCertificate == true &&
          business.ruc != null &&
          business.ruc!.isNotEmpty &&
          business.sunatUser != null &&
          business.sunatUser!.isNotEmpty &&
          business.sunatPassword != null &&
          business.sunatPassword!.isNotEmpty &&
          business.sunatPfxPassword != null &&
          business.sunatPfxPassword!.isNotEmpty;

      if (hasNubefact) {
        try {
          final customerDocType = customerDoc.trim().length == 11 ? '6' : '1';

          final nubefactItems = items.map((item) {
            final itemIgv = double.parse(
              (item.lineTotal - (item.lineTotal / 1.18)).toStringAsFixed(2),
            );
            return _nubefactService.buildItemPayload(
              description:
                  '${item.productName}${item.variantName.isNotEmpty ? " (${item.variantName})" : ""}',
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              igvAmount: itemIgv,
              lineTotal: item.lineTotal,
            );
          }).toList();

          final prefix = savedSale.number.split('-')[0];
          final correlativoStr = savedSale.number.split('-')[1];
          final correlativo = int.parse(correlativoStr);

          final payload = _nubefactService.buildInvoicePayload(
            documentType: documentType,
            serie: prefix,
            correlativo: correlativo,
            customerDocType: customerDocType,
            customerDoc: customerDoc.trim(),
            customerName: customerName.trim(),
            customerAddress: customerAddress.trim(),
            emissionDate: DateTime.now(),
            subtotal: subtotal,
            igv: igv,
            total: total,
            items: nubefactItems,
          );

          final nubefactResponse = await _nubefactService.emitInvoice(
            url: business.nubefactUrl!,
            token: business.nubefactToken!,
            payload: payload,
          );

          await updateSaleSunatStatusUseCase(
            businessSlug,
            savedSale.id,
            status: nubefactResponse.accepted ? 'accepted' : 'rejected',
            description: nubefactResponse.description,
            hash: nubefactResponse.hash,
            pdfUrl: nubefactResponse.pdfUrl,
            xmlUrl: nubefactResponse.xmlUrl,
            cdrUrl: nubefactResponse.cdrUrl,
          );

          if (!nubefactResponse.accepted) {
            throw Exception(
              "SUNAT rechazó el comprobante: ${nubefactResponse.description}",
            );
          }
        } catch (e) {
          await updateSaleSunatStatusUseCase(
            businessSlug,
            savedSale.id,
            status: 'rejected',
            description: e.toString(),
          );
          rethrow;
        }
      } else if (hasSunatDirect) {
        try {
          final customerDocType = customerDoc.trim().length == 11 ? '6' : '1';
          final tipoDocumento = documentType == 'factura'
              ? '01'
              : documentType == 'boleta'
                  ? '03'
                  : documentType == 'nota_credito'
                      ? '07'
                      : documentType == 'nota_debito'
                          ? '08'
                          : '03';

          final lines = items.map((item) {
            return {
              "codigo": item.productSku ?? item.productId,
              "descripcion":
                  '${item.productName}${item.variantName.isNotEmpty ? " (${item.variantName})" : ""}',
              "unidad": "ZZ",
              "cantidad": item.quantity.toStringAsFixed(2),
              "precio_unitario": item.unitPrice.toStringAsFixed(2),
              "igv_afectacion": "10",
            };
          }).toList();

          final prefix = savedSale.number.split('-')[0];
          final correlativoStr = savedSale.number.split('-')[1];
          final correlativo = int.parse(correlativoStr);

          final invoiceData = <String, dynamic>{
            "tipo_documento": tipoDocumento,
            "serie": prefix,
            "numero": correlativo,
            "fecha_emision": DateTime.now().toIso8601String().substring(0, 10),
            "moneda": "PEN",
            "receptor": {
              "tipo_doc": customerDocType,
              "numero_doc": customerDoc.trim(),
              "razon_social": customerName.trim(),
              "direccion": customerAddress.trim(),
            },
            "lines": lines,
          };

          if (motivoCodigo != null) {
            invoiceData["motivo_codigo"] = motivoCodigo;
            invoiceData["motivo_descripcion"] = motivoDescripcion ?? "";
          }
          if (refDocSerie != null && refDocNumero != null) {
            invoiceData["referencia"] = {
              "tipo_doc": refDocType ?? "01",
              "serie": refDocSerie,
              "numero": refDocNumero,
            };
          }

          final dio = Dio();
          dio.options.validateStatus = (status) => true;
          final functionUrl = dotenv.env['FUNCTION_EMIT_TO_SUNAT'] ??
              "https://us-central1-catalogo-virtual-app.cloudfunctions.net/emit_to_sunat";
          final response = await dio.post(functionUrl, data: {
            "businessId": businessSlug,
            "invoiceData": invoiceData,
            "certificatePassword": business.sunatPfxPassword,
          });

          if (response.statusCode == 200) {
            final success = response.data["success"] == true;
            await updateSaleSunatStatusUseCase(
              businessSlug,
              savedSale.id,
              status: success ? 'accepted' : 'rejected',
              description: response.data["description"],
              hash: response.data["hash"],
            );

            if (!success) {
              throw Exception(
                "SUNAT rechazó: ${response.data["description"] ?? response.data["error"]}",
              );
            }
          } else {
            throw Exception(
              "Error al emitir: ${response.data["error"] ?? "Error de conexión"}",
            );
          }
        } catch (e) {
          await updateSaleSunatStatusUseCase(
            businessSlug,
            savedSale.id,
            status: 'rejected',
            description: e.toString(),
          );
          rethrow;
        }
      }
    }

    await loadSales(businessSlug);
  }
}
