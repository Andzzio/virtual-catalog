import 'package:virtual_catalog_app/domain/entities/sale_item.dart';

class SaleItemModel extends SaleItem {
  SaleItemModel({
    required super.productId,
    required super.productName,
    super.productSku,
    required super.variantName,
    required super.quantity,
    required super.unitPrice,
    required super.lineTotal,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'variantName': variantName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productSku: json['productSku'],
      variantName: json['variantName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
