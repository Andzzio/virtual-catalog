import 'package:virtual_catalog_app/domain/entities/order.dart';

abstract class OrderRepository {
  Future<String> createOrder(Order order);
  Stream<Order> listenToOrder(String orderId);
}
