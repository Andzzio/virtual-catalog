import 'package:virtual_catalog_app/domain/datasources/role_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/role_entity.dart';
import 'package:virtual_catalog_app/domain/repos/role_repository.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleDatasource datasource;

  RoleRepositoryImpl({required this.datasource});

  @override
  Future<List<RoleEntity>> getRoles(String businessSlug) {
    return datasource.getRoles(businessSlug);
  }

  @override
  Future<void> createRole(String businessSlug, RoleEntity role) {
    return datasource.createRole(businessSlug, role);
  }

  @override
  Future<void> updateRole(String businessSlug, RoleEntity role) {
    return datasource.updateRole(businessSlug, role);
  }

  @override
  Future<void> updateRolePositions(
      String businessSlug, List<Map<String, dynamic>> positions) {
    return datasource.updateRolePositions(businessSlug, positions);
  }

  @override
  Future<void> deleteRole(String businessSlug, String roleId) {
    return datasource.deleteRole(businessSlug, roleId);
  }
}
