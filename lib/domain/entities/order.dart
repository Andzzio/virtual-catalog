import 'package:virtual_catalog_app/domain/entities/cart_item.dart';

class Order {
  final String? id;
  final String businessId;
  final String customerName;
  final String customerLastName;
  final String customerPhone;
  final String customerDni;
  final String? customerCountry;
  final String customerAddress;
  final String customerDepartamento;
  final String customerProvincia;
  final String customerDistrito;
  final String? customerUbigeoCode;
  final String? customerZip;
  final String? notes;
  final String? customerEmail;
  final List<CartItem> items;
  final double total;
  final String status;
  final String paymentMethod;
  final String? deliveryMethod;
  final DateTime createdAt;
  final bool isBillingSameAsShipping;
  final String? billingName;
  final String? billingLastName;
  final String? billingCompany;
  final String? billingCountry;
  final String? billingAddress;
  final String? billingReference;
  final String? billingDepartamento;
  final String? billingProvincia;
  final String? billingDistrito;
  final String? billingZip;
  final String? billingPhone;

  Order({
    this.id,
    required this.businessId,
    required this.customerName,
    required this.customerLastName,
    required this.customerPhone,
    required this.customerDni,
    this.customerCountry,
    required this.customerAddress,
    required this.customerDepartamento,
    required this.customerProvincia,
    required this.customerDistrito,
    this.customerUbigeoCode,
    this.customerZip,
    this.notes,
    this.customerEmail,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.deliveryMethod,
    required this.createdAt,
    this.isBillingSameAsShipping = true,
    this.billingName,
    this.billingLastName,
    this.billingCompany,
    this.billingCountry,
    this.billingAddress,
    this.billingReference,
    this.billingDepartamento,
    this.billingProvincia,
    this.billingDistrito,
    this.billingZip,
    this.billingPhone,
  });
}
