import 'package:virtual_catalog_app/domain/repos/user_repository.dart';

class UpdateUserRoles {
  final UserRepository repository;

  UpdateUserRoles(this.repository);

  Future<void> call(String userId, List<String> roles) {
    return repository.updateUserRoles(userId, roles);
  }
}
