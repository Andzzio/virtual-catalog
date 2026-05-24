import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/domain/entities/stock_movement.dart';

class StockMovementModel extends StockMovement {
  StockMovementModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productSku,
    required super.variantName,
    required super.type,
    required super.quantity,
    required super.stockAfter,
    super.reason,
    super.reference,
    required super.userId,
    required super.userName,
    required super.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'variantName': variantName,
      'type': type,
      'quantity': quantity,
      'stockAfter': stockAfter,
      'reason': reason,
      'reference': reference,
      'userId': userId,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StockMovementModel.fromFirestore(Map<String, dynamic> json, String docId) {
    final createdAtData = json['createdAt'];
    DateTime parsedDate;
    if (createdAtData is Timestamp) {
      parsedDate = createdAtData.toDate();
    } else if (createdAtData is String) {
      parsedDate = DateTime.parse(createdAtData);
    } else {
      parsedDate = DateTime.now();
    }

    return StockMovementModel(
      id: docId,
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productSku: json['productSku'],
      variantName: json['variantName'] ?? '',
      type: json['type'] ?? 'ingreso',
      quantity: json['quantity'] ?? 0,
      stockAfter: json['stockAfter'] ?? 0,
      reason: json['reason'],
      reference: json['reference'],
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      createdAt: parsedDate,
    );
  }
}
