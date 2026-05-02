import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:virtual_catalog_app/data/models/order_model.dart';
import 'package:virtual_catalog_app/domain/entities/order.dart';
import 'package:virtual_catalog_app/domain/repos/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> createOrder(Order order) async {
    final docRef = _firestore.collection('orders').doc();
    final model = OrderModel.fromEntity(order);
    await docRef.set(model.toJson());
    
    await _firestore
        .collection('businesses')
        .doc(order.businessId)
        .collection('orders')
        .doc(docRef.id)
        .set(model.toJson());
        
    return docRef.id;
  }

  @override
  Stream<Order> listenToOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map<Order>((snapshot) {
          if (!snapshot.exists) {
            throw Exception("Orden no encontrada");
          }
          return OrderModel.fromJson(snapshot.data()!, snapshot.id);
        });
  }

  @override
  Future<void> updateOrderStatus(String businessId, String orderId, String newStatus) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});

    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});
  }

  @override
  Stream<List<Order>> listenToBusinessOrders(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
