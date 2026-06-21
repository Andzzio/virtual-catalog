import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/role_entity.dart';
import 'package:virtual_catalog_app/domain/usecases/create_role.dart';
import 'package:virtual_catalog_app/domain/usecases/delete_role.dart';
import 'package:virtual_catalog_app/domain/usecases/get_roles.dart';
import 'package:virtual_catalog_app/domain/usecases/update_role.dart';
import 'package:virtual_catalog_app/domain/usecases/update_role_positions.dart';

class RolesProvider extends ChangeNotifier {
  final GetRoles getRolesUseCase;
  final CreateRole createRoleUseCase;
  final UpdateRole updateRoleUseCase;
  final UpdateRolePositions updateRolePositionsUseCase;
  final DeleteRole deleteRoleUseCase;

  List<RoleEntity> _roles = [];
  bool _isLoading = false;
  String _errorMsg = '';

  RolesProvider({
    required this.getRolesUseCase,
    required this.createRoleUseCase,
    required this.updateRoleUseCase,
    required this.updateRolePositionsUseCase,
    required this.deleteRoleUseCase,
  });

  List<RoleEntity> get roles => _roles;
  bool get isLoading => _isLoading;
  String get errorMsg => _errorMsg;

  Future<void> loadRoles(String businessSlug) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();
    try {
      _roles = await getRolesUseCase(businessSlug);
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRole(String businessSlug, RoleEntity role) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();
    try {
      await createRoleUseCase(businessSlug, role);
      await loadRoles(businessSlug);
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRole(String businessSlug, RoleEntity role) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();
    try {
      await updateRoleUseCase(businessSlug, role);
      await loadRoles(businessSlug);
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRolePositions(
      String businessSlug, List<Map<String, dynamic>> positions) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();
    try {
      await updateRolePositionsUseCase(businessSlug, positions);
      await loadRoles(businessSlug);
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRole(String businessSlug, String roleId) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();
    try {
      await deleteRoleUseCase(businessSlug, roleId);
      await loadRoles(businessSlug);
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
