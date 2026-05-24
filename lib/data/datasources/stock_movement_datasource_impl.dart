import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/stock_movement_model.dart';
import 'package:virtual_catalog_app/domain/datasources/stock_movement_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/stock_movement.dart';

class StockMovementDatasourceImpl implements StockMovementDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<StockMovement>> getMovements(String businessSlug) async {
    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('stock_movements')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => StockMovementModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> registerMovement(String businessSlug, StockMovement movement) async {
    final model = StockMovementModel(
      id: movement.id,
      productId: movement.productId,
      productName: movement.productName,
      productSku: movement.productSku,
      variantName: movement.variantName,
      type: movement.type,
      quantity: movement.quantity,
      stockAfter: movement.stockAfter,
      reason: movement.reason,
      reference: movement.reference,
      userId: movement.userId,
      userName: movement.userName,
      createdAt: movement.createdAt,
    );

    await _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('stock_movements')
        .add(model.toFirestore());
  }
}
