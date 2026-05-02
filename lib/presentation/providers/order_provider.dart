import 'dart:async';
import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/order.dart';
import 'package:virtual_catalog_app/domain/repos/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository repository;

  OrderProvider({required this.repository});

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  StreamSubscription? _ordersSub;

  // Métricas
  double get totalSalesThisMonth {
    final now = DateTime.now();
    return _orders
        .where((o) =>
            o.status == 'paid' &&
            o.createdAt.month == now.month &&
            o.createdAt.year == now.year)
        .fold(0.0, (sum, o) => sum + o.total);
  }

  int get paidOrdersThisMonth {
    final now = DateTime.now();
    return _orders
        .where((o) =>
            o.status == 'paid' &&
            o.createdAt.month == now.month &&
            o.createdAt.year == now.year)
        .length;
  }

  int get pendingOrdersCount =>
      _orders.where((o) => o.status == 'pending').length;

  Future<String> createOrder(Order order) async {
    return await repository.createOrder(order);
  }

  Stream<Order> listenToOrder(String orderId) {
    return repository.listenToOrder(orderId);
  }

  void listenToBusinessOrders(String businessId) {
    _ordersSub?.cancel();
    _ordersSub =
        repository.listenToBusinessOrders(businessId).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  Future<void> updateOrderStatus(String businessId, String orderId, String newStatus) async {
    await repository.updateOrderStatus(businessId, orderId, newStatus);
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }
}
