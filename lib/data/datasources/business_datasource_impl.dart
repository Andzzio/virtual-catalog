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

  @override
  Future<Business?> getBusinessByDomain(String domain) async {
    final snapshot = await _db
        .collection("businesses")
        .where("customDomain", isEqualTo: domain)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return BusinessModel.fromFirestore(snapshot.docs.first).toEntity();
  }

  @override
  Future<void> updateBusiness(String slug, Business business) async {
    final model = BusinessModel.fromEntity(business);
    await _db.collection("businesses").doc(slug).update(model.toJson());
  }
}
