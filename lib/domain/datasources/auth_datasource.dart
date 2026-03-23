import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthDatasource {
  Future<UserCredential> loginWithEmailPassword(String email, String password);
  Future<void> logout();
  Future<void> resetPassword(String email);
  User? getCurrentUser();
  Stream<User?> get authStateChanges;
}
