import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/order.dart';
import 'package:virtual_catalog_app/domain/repos/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository repository;

  OrderProvider({required this.repository});

  Future<String> createOrder(Order order) async {
    return await repository.createOrder(order);
  }

  Stream<Order> listenToOrder(String orderId) {
    return repository.listenToOrder(orderId);
  }
}
