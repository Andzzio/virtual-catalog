import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/sale_item_model.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';

class SaleModel extends Sale {
  SaleModel({
    required super.id,
    required super.number,
    required super.documentType,
    required super.customerName,
    required super.customerDoc,
    required super.customerAddress,
    required super.customerPhone,
    required super.paymentMethod,
    required super.subtotal,
    required super.igv,
    required super.total,
    required super.notes,
    required super.userId,
    required super.userName,
    required super.createdAt,
    required super.items,
    super.sunatStatus,
    super.sunatDescription,
    super.sunatHash,
    super.pdfUrl,
    super.xmlUrl,
    super.cdrUrl,
    super.motivoCodigo,
    super.motivoDescripcion,
    super.refDocSerie,
    super.refDocNumero,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'number': number,
      'documentType': documentType,
      'customerName': customerName,
      'customerDoc': customerDoc,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'igv': igv,
      'total': total,
      'notes': notes,
      'userId': userId,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((i) {
        if (i is SaleItemModel) {
          return i.toFirestore();
        }
        return SaleItemModel(
          productId: i.productId,
          productName: i.productName,
          productSku: i.productSku,
          variantName: i.variantName,
          quantity: i.quantity,
          unitPrice: i.unitPrice,
          lineTotal: i.lineTotal,
        ).toFirestore();
      }).toList(),
      if (sunatStatus != null) 'sunatStatus': sunatStatus,
      if (sunatDescription != null) 'sunatDescription': sunatDescription,
      if (sunatHash != null) 'sunatHash': sunatHash,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
      if (xmlUrl != null) 'xmlUrl': xmlUrl,
      if (cdrUrl != null) 'cdrUrl': cdrUrl,
      if (motivoCodigo != null) 'motivoCodigo': motivoCodigo,
      if (motivoDescripcion != null) 'motivoDescripcion': motivoDescripcion,
      if (refDocSerie != null) 'refDocSerie': refDocSerie,
      if (refDocNumero != null) 'refDocNumero': refDocNumero,
    };
  }

  factory SaleModel.fromFirestore(Map<String, dynamic> json, String docId) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((item) {
      return SaleItemModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();

    return SaleModel(
      id: docId,
      number: json['number'] ?? '',
      documentType: json['documentType'] ?? 'boleta',
      customerName: json['customerName'] ?? '',
      customerDoc: json['customerDoc'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'efectivo',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      igv: (json['igv'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: itemsList,
      sunatStatus: json['sunatStatus'],
      sunatDescription: json['sunatDescription'],
      sunatHash: json['sunatHash'],
      pdfUrl: json['pdfUrl'],
      xmlUrl: json['xmlUrl'],
      cdrUrl: json['cdrUrl'],
      motivoCodigo: json['motivoCodigo'],
      motivoDescripcion: json['motivoDescripcion'],
      refDocSerie: json['refDocSerie'],
      refDocNumero: json['refDocNumero'],
    );
  }
}
