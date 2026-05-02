import 'package:virtual_catalog_app/data/models/cart_item_model.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';
import 'package:virtual_catalog_app/domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    super.id,
    required super.businessId,
    required super.customerName,
    required super.customerLastName,
    required super.customerPhone,
    required super.customerDni,
    required super.customerAddress,
    required super.customerCity,
    required super.customerRegion,
    super.customerZip,
    super.notes,
    super.customerEmail,
    required super.items,
    required super.total,
    required super.status,
    required super.paymentMethod,
    super.deliveryMethod,
    required super.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessId': businessId,
      'customerName': customerName,
      'customerLastName': customerLastName,
      'customerPhone': customerPhone,
      'customerDni': customerDni,
      'customerAddress': customerAddress,
      'customerCity': customerCity,
      'customerRegion': customerRegion,
      'customerZip': customerZip,
      'notes': notes,
      'customerEmail': customerEmail,
      'items': items.map((x) => CartItemModel.fromEntity(x).toJson()).toList(),
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'deliveryMethod': deliveryMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json, String id) {
    return OrderModel(
      id: id,
      businessId: json['businessId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerLastName: json['customerLastName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerDni: json['customerDni'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerCity: json['customerCity'] ?? '',
      customerRegion: json['customerRegion'] ?? '',
      customerZip: json['customerZip'],
      notes: json['notes'],
      customerEmail: json['customerEmail'],
      items: List<CartItem>.from(
        json['items']?.map((x) => CartItemModel.fromJson(x).toEntity()) ?? [],
      ),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? '',
      deliveryMethod: json['deliveryMethod'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static OrderModel fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      businessId: order.businessId,
      customerName: order.customerName,
      customerLastName: order.customerLastName,
      customerPhone: order.customerPhone,
      customerDni: order.customerDni,
      customerAddress: order.customerAddress,
      customerCity: order.customerCity,
      customerRegion: order.customerRegion,
      customerZip: order.customerZip,
      notes: order.notes,
      customerEmail: order.customerEmail,
      items: order.items,
      total: order.total,
      status: order.status,
      paymentMethod: order.paymentMethod,
      deliveryMethod: order.deliveryMethod,
      createdAt: order.createdAt,
    );
  }
}
