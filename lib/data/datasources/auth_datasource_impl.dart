import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_catalog_app/domain/datasources/auth_datasource.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Future<UserCredential> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
