import 'package:virtual_catalog_app/domain/repos/user_repository.dart';

class UpdateUserRole {
  final UserRepository repository;

  UpdateUserRole(this.repository);

  Future<void> call(String userId, String role) {
    return repository.updateUserRole(userId, role);
  }
}
