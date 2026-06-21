import 'package:virtual_catalog_app/domain/entities/role_entity.dart';
import 'package:virtual_catalog_app/domain/repos/role_repository.dart';

class GetRoles {
  final RoleRepository repository;

  GetRoles(this.repository);

  Future<List<RoleEntity>> call(String businessSlug) {
    return repository.getRoles(businessSlug);
  }
}
