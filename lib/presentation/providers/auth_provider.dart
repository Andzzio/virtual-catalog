import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/repos/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  User? _user;
  bool _isLoading = true;
  String _errorMsg = "";

  AuthProvider({required this.authRepository}) {
    _init();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get errorMsg => _errorMsg;

  void _init() {
    authRepository.authStateChanges.listen((User? newUser) {
      _user = newUser;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMsg = "";
      notifyListeners();
      await authRepository.loginWithEmailPassword(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == "user-not-found" ||
          e.code == "invalid-credential" ||
          e.code == "wrong-password") {
        _errorMsg = "Correo o contraseña incorrectos.";
      } else {
        _errorMsg = "Error : ${e.message}";
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMsg = "Error inesperado.";
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await authRepository.logout();
    } catch (e) {
      _isLoading = false;
      _errorMsg = "Error al cerrar sesión.";
      notifyListeners();
    }
  }
}
