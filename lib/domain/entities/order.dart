import 'package:virtual_catalog_app/domain/entities/cart_item.dart';

class Order {
  final String? id;
  final String businessId;
  final String customerName;
  final String customerLastName;
  final String customerPhone;
  final String customerDni;
  final String customerAddress;
  final String customerCity;
  final String customerRegion;
  final String? customerZip;
  final String? notes;
  final String? customerEmail;
  final List<CartItem> items;
  final double total;
  final String status; // 'pending', 'paid', 'failed'
  final String paymentMethod;
  final String? deliveryMethod;
  final DateTime createdAt;

  Order({
    this.id,
    required this.businessId,
    required this.customerName,
    required this.customerLastName,
    required this.customerPhone,
    required this.customerDni,
    required this.customerAddress,
    required this.customerCity,
    required this.customerRegion,
    this.customerZip,
    this.notes,
    this.customerEmail,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.deliveryMethod,
    required this.createdAt,
  });
}
