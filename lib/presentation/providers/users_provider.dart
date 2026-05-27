import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/user_entity.dart';
import 'package:virtual_catalog_app/domain/usecases/create_user.dart';
import 'package:virtual_catalog_app/domain/usecases/delete_user.dart';
import 'package:virtual_catalog_app/domain/usecases/get_users.dart';
import 'package:virtual_catalog_app/domain/usecases/update_user_role.dart';

class UsersProvider extends ChangeNotifier {
  final GetUsers getUsersUseCase;
  final CreateUser createUserUseCase;
  final DeleteUser deleteUserUseCase;
  final UpdateUserRole updateUserRoleUseCase;

  List<UserEntity> _users = [];
  bool _isLoading = false;
  String _errorMsg = '';

  UsersProvider({
    required this.getUsersUseCase,
    required this.createUserUseCase,
    required this.deleteUserUseCase,
    required this.updateUserRoleUseCase,
  });

  List<UserEntity> get users => _users;
  bool get isLoading => _isLoading;
  String get errorMsg => _errorMsg;

  Future<void> loadUsers(String businessSlug) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();
    try {
      _users = await getUsersUseCase(businessSlug);
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser({
    required String businessSlug,
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();
    try {
      await createUserUseCase(
        businessSlug: businessSlug,
        name: name,
        email: email,
        password: password,
        role: role,
      );
      await loadUsers(businessSlug);
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String businessSlug, String userId) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();
    try {
      await deleteUserUseCase(userId);
      await loadUsers(businessSlug);
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserRole(String businessSlug, String userId, String role) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();
    try {
      await updateUserRoleUseCase(userId, role);
      await loadUsers(businessSlug);
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
