import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/shipping_zone_model.dart';
import 'package:virtual_catalog_app/domain/datasources/shipping_zone_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/shipping_zone.dart';

class ShippingZoneDatasourceImpl implements ShippingZoneDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _zonesRef(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('shipping_zones');
  }

  @override
  Future<List<ShippingZone>> getZones(String businessId) async {
    final snapshot = await _zonesRef(businessId).get();
    return snapshot.docs
        .map((doc) => ShippingZoneModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<void> saveZones(String businessId, List<ShippingZone> zones) async {
    final batch = _firestore.batch();
    final ref = _zonesRef(businessId);

    final existing = await ref.get();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final zone in zones) {
      final model = ShippingZoneModel.fromEntity(zone);
      batch.set(ref.doc(), model.toFirestore());
    }

    await batch.commit();
  }

  @override
  Future<void> deleteAllZones(String businessId) async {
    final batch = _firestore.batch();
    final snapshot = await _zonesRef(businessId).get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
