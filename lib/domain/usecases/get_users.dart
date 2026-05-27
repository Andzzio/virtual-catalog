import 'package:virtual_catalog_app/domain/entities/user_entity.dart';
import 'package:virtual_catalog_app/domain/repos/user_repository.dart';

class GetUsers {
  final UserRepository repository;

  GetUsers(this.repository);

  Future<List<UserEntity>> call(String businessSlug) {
    return repository.getUsers(businessSlug);
  }
}
