import 'package:virtual_catalog_app/domain/entities/sale_item.dart';

class Sale {
  final String id;
  final String number;
  final String documentType;
  final String customerName;
  final String customerDoc;
  final String customerAddress;
  final String customerPhone;
  final String paymentMethod;
  final double subtotal;
  final double igv;
  final double total;
  final String notes;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final List<SaleItem> items;
  final String? sunatStatus;
  final String? sunatDescription;
  final String? sunatHash;
  final String? pdfUrl;
  final String? xmlUrl;
  final String? cdrUrl;
  final String? motivoCodigo;
  final String? motivoDescripcion;
  final String? refDocSerie;
  final int? refDocNumero;

  Sale({
    required this.id,
    required this.number,
    required this.documentType,
    required this.customerName,
    required this.customerDoc,
    required this.customerAddress,
    required this.customerPhone,
    required this.paymentMethod,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.notes,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.items,
    this.sunatStatus,
    this.sunatDescription,
    this.sunatHash,
    this.pdfUrl,
    this.xmlUrl,
    this.cdrUrl,
    this.motivoCodigo,
    this.motivoDescripcion,
    this.refDocSerie,
    this.refDocNumero,
  });
}
