import 'package:virtual_catalog_app/domain/entities/role_entity.dart';
import 'package:virtual_catalog_app/domain/repos/role_repository.dart';

class CreateRole {
  final RoleRepository repository;

  CreateRole(this.repository);

  Future<void> call(String businessSlug, RoleEntity role) {
    return repository.createRole(businessSlug, role);
  }
}
