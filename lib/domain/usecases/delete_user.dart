import 'package:virtual_catalog_app/domain/repos/user_repository.dart';

class DeleteUser {
  final UserRepository repository;

  DeleteUser(this.repository);

  Future<void> call(String userId) {
    return repository.deleteUser(userId);
  }
}
