import 'package:virtual_catalog_app/domain/repos/role_repository.dart';

class UpdateRolePositions {
  final RoleRepository repository;

  UpdateRolePositions(this.repository);

  Future<void> call(String businessSlug, List<Map<String, dynamic>> positions) {
    return repository.updateRolePositions(businessSlug, positions);
  }
}
