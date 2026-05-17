import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:virtual_catalog_app/data/models/ubigeo_model.dart';
import 'package:virtual_catalog_app/domain/datasources/ubigeo_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';

class UbigeoDatasourceImpl implements UbigeoDatasource {
  final Dio _dio;

  static const _baseUrl = 'https://cdn.jsdelivr.net/gh/joseluisq/ubigeos-peru@master/json';

  List<Ubigeo>? _cachedDepartamentos;
  Map<String, List<Ubigeo>>? _cachedProvincias;
  Map<String, List<Ubigeo>>? _cachedDistritos;

  UbigeoDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<Ubigeo>> getDepartamentos() async {
    if (_cachedDepartamentos != null) return _cachedDepartamentos!;

    final response = await _dio.get('$_baseUrl/departamentos.json');
    final List<dynamic> data = response.data is String
        ? jsonDecode(response.data)
        : response.data;

    _cachedDepartamentos = data
        .map((json) => UbigeoModel.fromJson(json).toEntity())
        .toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));

    return _cachedDepartamentos!;
  }

  @override
  Future<List<Ubigeo>> getProvincias(String departamentoId) async {
    if (_cachedProvincias != null && _cachedProvincias!.containsKey(departamentoId)) {
      return _cachedProvincias![departamentoId]!;
    }

    _cachedProvincias ??= await _fetchAllProvincias();

    return _cachedProvincias![departamentoId] ?? [];
  }

  @override
  Future<List<Ubigeo>> getDistritos(String provinciaId) async {
    if (_cachedDistritos != null && _cachedDistritos!.containsKey(provinciaId)) {
      return _cachedDistritos![provinciaId]!;
    }

    _cachedDistritos ??= await _fetchAllDistritos();

    return _cachedDistritos![provinciaId] ?? [];
  }

  Future<Map<String, List<Ubigeo>>> _fetchAllProvincias() async {
    final response = await _dio.get('$_baseUrl/provincias.json');
    final Map<String, dynamic> data = response.data is String
        ? jsonDecode(response.data)
        : response.data;

    final result = <String, List<Ubigeo>>{};
    for (final entry in data.entries) {
      final list = (entry.value as List<dynamic>)
          .map((json) => UbigeoModel.fromJson(json).toEntity())
          .toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre));
      result[entry.key] = list;
    }
    return result;
  }

  Future<Map<String, List<Ubigeo>>> _fetchAllDistritos() async {
    final response = await _dio.get('$_baseUrl/distritos.json');
    final Map<String, dynamic> data = response.data is String
        ? jsonDecode(response.data)
        : response.data;

    final result = <String, List<Ubigeo>>{};
    for (final entry in data.entries) {
      final list = (entry.value as List<dynamic>)
          .map((json) => UbigeoModel.fromJson(json).toEntity())
          .toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre));
      result[entry.key] = list;
    }
    return result;
  }
}
