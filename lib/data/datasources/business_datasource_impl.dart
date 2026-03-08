import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/business_model.dart';
import 'package:virtual_catalog_app/domain/datasources/business_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';

class BusinessDatasourceImpl implements BusinessDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<Business?> getBusinessBySlug(String slug) async {
    final doc = await _db.collection("businesses").doc(slug).get();
    if (!doc.exists) return null;
    return BusinessModel.fromFirestore(doc).toEntity();
  }
}
