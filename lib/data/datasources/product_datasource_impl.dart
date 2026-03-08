import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/product_model.dart';
import 'package:virtual_catalog_app/domain/datasources/product_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';

class ProductDatasourceImpl implements ProductDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<Product>> getProducts(String businessSlug) async {
    final snapshot = await _db
        .collection("products")
        .where("businessId", isEqualTo: businessSlug)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<Product?> getProductById(String businessSlug, String productId) async {
    final doc = await _db.collection("products").doc(productId).get();
    if (!doc.exists) return null;
    final product = ProductModel.fromFirestore(doc).toEntity();

    if (product.businessId != businessSlug) return null;

    return product;
  }
}
