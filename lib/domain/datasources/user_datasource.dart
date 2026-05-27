import 'package:virtual_catalog_app/domain/entities/user_entity.dart';

abstract class UserDatasource {
  Future<List<UserEntity>> getUsers(String businessSlug);
  Future<void> createUser({
    required String businessSlug,
    required String name,
    required String email,
    required String password,
    required String role,
  });
  Future<void> deleteUser(String userId);
  Future<void> updateUserRole(String userId, String role);
}
