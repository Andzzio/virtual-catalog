import 'package:virtual_catalog_app/domain/repos/role_repository.dart';

class DeleteRole {
  final RoleRepository repository;

  DeleteRole(this.repository);

  Future<void> call(String businessSlug, String roleId) {
    return repository.deleteRole(businessSlug, roleId);
  }
}
