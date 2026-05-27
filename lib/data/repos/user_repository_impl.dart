import 'package:virtual_catalog_app/domain/datasources/user_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/user_entity.dart';
import 'package:virtual_catalog_app/domain/repos/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDatasource datasource;

  UserRepositoryImpl({required this.datasource});

  @override
  Future<List<UserEntity>> getUsers(String businessSlug) {
    return datasource.getUsers(businessSlug);
  }

  @override
  Future<void> createUser({
    required String businessSlug,
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return datasource.createUser(
      businessSlug: businessSlug,
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<void> deleteUser(String userId) {
    return datasource.deleteUser(userId);
  }

  @override
  Future<void> updateUserRole(String userId, String role) {
    return datasource.updateUserRole(userId, role);
  }
}
