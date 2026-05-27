import 'package:virtual_catalog_app/domain/repos/user_repository.dart';

class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<void> call({
    required String businessSlug,
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return repository.createUser(
      businessSlug: businessSlug,
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}
