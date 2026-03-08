import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_catalog_app/domain/datasources/auth_datasource.dart';
import 'package:virtual_catalog_app/domain/repos/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl({required this.datasource});

  @override
  Stream<User?> get authStateChanges => datasource.authStateChanges;

  @override
  User? getCurrentUser() {
    return datasource.getCurrentUser();
  }

  @override
  Future<UserCredential> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    return datasource.loginWithEmailPassword(email, password);
  }

  @override
  Future<void> logout() async {
    return datasource.logout();
  }
}
