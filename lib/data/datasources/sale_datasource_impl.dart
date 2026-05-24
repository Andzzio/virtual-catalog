import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/sale_model.dart';
import 'package:virtual_catalog_app/domain/datasources/sale_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';

class SaleDatasourceImpl implements SaleDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Sale>> getSales(String businessSlug) async {
    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('sales')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SaleModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> createSale(String businessSlug, Sale sale) async {
    final model = SaleModel(
      id: sale.id,
      number: sale.number,
      documentType: sale.documentType,
      customerName: sale.customerName,
      customerDoc: sale.customerDoc,
      customerAddress: sale.customerAddress,
      customerPhone: sale.customerPhone,
      paymentMethod: sale.paymentMethod,
      subtotal: sale.subtotal,
      igv: sale.igv,
      total: sale.total,
      notes: sale.notes,
      userId: sale.userId,
      userName: sale.userName,
      createdAt: sale.createdAt,
      items: sale.items,
    );

    await _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('sales')
        .add(model.toFirestore());
  }
}
