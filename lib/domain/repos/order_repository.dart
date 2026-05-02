import 'package:virtual_catalog_app/domain/entities/order.dart';

abstract class OrderRepository {
  Future<String> createOrder(Order order);
  Stream<Order> listenToOrder(String orderId);
  Stream<List<Order>> listenToBusinessOrders(String businessId);
  Future<void> updateOrderStatus(String businessId, String orderId, String newStatus);
}
