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

  @override
  Future<void> deleteOrder(String businessId, String orderId) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .delete();

    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('orders')
        .doc(orderId)
        .delete();
  }

  @override
  Future<void> deleteStalePendingOrders(String businessId, {int daysThreshold = 7}) async {
    final thresholdDate = DateTime.now().subtract(Duration(days: daysThreshold));
    
    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final createdAtStr = data['createdAt'] as String?;
      if (createdAtStr != null) {
        final createdAt = DateTime.tryParse(createdAtStr);
        if (createdAt != null && createdAt.isBefore(thresholdDate)) {
          // delete from subcollection
          await doc.reference.delete();
          // delete from global
          await _firestore.collection('orders').doc(doc.id).delete();
        }
      }
    }
  }
}
