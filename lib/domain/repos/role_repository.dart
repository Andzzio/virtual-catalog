import 'package:virtual_catalog_app/domain/entities/role_entity.dart';

abstract class RoleRepository {
  Future<List<RoleEntity>> getRoles(String businessSlug);
  Future<void> createRole(String businessSlug, RoleEntity role);
  Future<void> updateRole(String businessSlug, RoleEntity role);
  Future<void> updateRolePositions(String businessSlug, List<Map<String, dynamic>> positions);
  Future<void> deleteRole(String businessSlug, String roleId);
}
