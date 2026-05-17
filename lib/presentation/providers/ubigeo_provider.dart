import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';
import 'package:virtual_catalog_app/domain/usecases/get_departamentos.dart';
import 'package:virtual_catalog_app/domain/usecases/get_provincias.dart';
import 'package:virtual_catalog_app/domain/usecases/get_distritos.dart';

class UbigeoProvider extends ChangeNotifier {
  final GetDepartamentos _getDepartamentos;
  final GetProvincias _getProvincias;
  final GetDistritos _getDistritos;

  List<Ubigeo> _departamentos = [];
  final Map<String, List<Ubigeo>> _provincias = {};
  final Map<String, List<Ubigeo>> _distritos = {};
  bool _isLoading = false;

  List<Ubigeo> get departamentos => _departamentos;
  bool get isLoading => _isLoading;

  UbigeoProvider({
    required GetDepartamentos getDepartamentos,
    required GetProvincias getProvincias,
    required GetDistritos getDistritos,
  })  : _getDepartamentos = getDepartamentos,
        _getProvincias = getProvincias,
        _getDistritos = getDistritos;

  Future<void> loadDepartamentos() async {
    if (_departamentos.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _departamentos = await _getDepartamentos();
    } catch (e) {
      debugPrint('Error loading departamentos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Ubigeo> getProvinciasFor(String departamentoId) {
    return _provincias[departamentoId] ?? [];
  }

  Future<List<Ubigeo>> loadProvincias(String departamentoId) async {
    if (_provincias.containsKey(departamentoId)) {
      return _provincias[departamentoId]!;
    }
    try {
      final result = await _getProvincias(departamentoId);
      _provincias[departamentoId] = result;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Error loading provincias: $e');
      return [];
    }
  }

  List<Ubigeo> getDistritosFor(String provinciaId) {
    return _distritos[provinciaId] ?? [];
  }

  Future<List<Ubigeo>> loadDistritos(String provinciaId) async {
    if (_distritos.containsKey(provinciaId)) {
      return _distritos[provinciaId]!;
    }
    try {
      final result = await _getDistritos(provinciaId);
      _distritos[provinciaId] = result;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Error loading distritos: $e');
      return [];
    }
  }
}
