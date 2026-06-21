import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/role_model.dart';
import 'package:virtual_catalog_app/domain/datasources/role_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/role_entity.dart';

class RoleDatasourceImpl implements RoleDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<RoleEntity>> getRoles(String businessSlug) async {
    final snapshot = await _db
        .collection("roles")
        .where("businessId", isEqualTo: businessSlug)
        .orderBy("position")
        .get();
    return snapshot.docs
        .map((doc) => RoleModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> createRole(String businessSlug, RoleEntity role) async {
    final model = RoleModel(
      id: role.id,
      businessId: businessSlug,
      name: role.name,
      colorValue: role.colorValue,
      position: role.position,
      permissions: role.permissions,
    );
    final ref = role.id.isEmpty
        ? _db.collection("roles").doc()
        : _db.collection("roles").doc(role.id);
    await ref.set(model.toFirestore());
  }

  @override
  Future<void> updateRole(String businessSlug, RoleEntity role) async {
    final model = RoleModel(
      id: role.id,
      businessId: businessSlug,
      name: role.name,
      colorValue: role.colorValue,
      position: role.position,
      permissions: role.permissions,
    );
    await _db.collection("roles").doc(role.id).update(model.toFirestore());
  }

  @override
  Future<void> updateRolePositions(
      String businessSlug, List<Map<String, dynamic>> positions) async {
    final batch = _db.batch();
    for (final pos in positions) {
      final roleId = pos['id'] as String;
      final position = pos['position'] as int;
      final ref = _db.collection("roles").doc(roleId);
      batch.update(ref, {'position': position});
    }
    await batch.commit();
  }

  @override
  Future<void> deleteRole(String businessSlug, String roleId) async {
    await _db.collection("roles").doc(roleId).delete();
  }
}
