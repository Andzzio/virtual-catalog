import 'package:virtual_catalog_app/domain/entities/role_entity.dart';
import 'package:virtual_catalog_app/domain/repos/role_repository.dart';

class UpdateRole {
  final RoleRepository repository;

  UpdateRole(this.repository);

  Future<void> call(String businessSlug, RoleEntity role) {
    return repository.updateRole(businessSlug, role);
  }
}
