import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/domain/entities/role_entity.dart';

class RoleModel extends RoleEntity {
  RoleModel({
    required super.id,
    required super.businessId,
    required super.name,
    required super.colorValue,
    required super.position,
    required super.permissions,
  });

  factory RoleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoleModel(
      id: doc.id,
      businessId: data['businessId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      colorValue: data['colorValue'] as int? ?? 4280397793,
      position: data['position'] as int? ?? 0,
      permissions: List<String>.from(data['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'name': name,
      'colorValue': colorValue,
      'position': position,
      'permissions': permissions,
    };
  }
}
