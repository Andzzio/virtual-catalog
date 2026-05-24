import 'package:dio/dio.dart';

class DniRucResult {
  final String name;
  final String? address;

  DniRucResult({required this.name, this.address});
}

class DniRucService {
  final Dio _dio = Dio();

  Future<DniRucResult> queryDocument({
    required String docNumber,
    required String token,
  }) async {
    final cleanDoc = docNumber.trim();
    if (cleanDoc.length == 8) {
      final response = await _dio.get(
        'https://dniruc.apisperu.com/api/v1/dni/$cleanDoc',
        queryParameters: {'token': token},
      );
      if (response.data == null) {
        throw Exception('Respuesta vacía de la API');
      }
      final data = response.data;
      final nombres = data['nombres'] ?? '';
      final apPaterno = data['apellidoPaterno'] ?? '';
      final apMaterno = data['apellidoMaterno'] ?? '';
      final name = '$nombres $apPaterno $apMaterno'.trim();
      if (name.isEmpty) {
        final altName = data['nombre'] ?? data['nombre_completo'] ?? '';
        if (altName.toString().isEmpty) {
          throw Exception('No se encontraron datos del DNI');
        }
        return DniRucResult(name: altName.toString().trim());
      }
      return DniRucResult(name: name);
    } else if (cleanDoc.length == 11) {
      final response = await _dio.get(
        'https://dniruc.apisperu.com/api/v1/ruc/$cleanDoc',
        queryParameters: {'token': token},
      );
      if (response.data == null) {
        throw Exception('Respuesta vacía de la API');
      }
      final data = response.data;
      final razonSocial = data['razonSocial'] ?? data['nombre_o_razon_social'] ?? data['nombre'] ?? '';
      final direccion = data['direccion'] ?? data['direccion_completa'] ?? '';
      if (razonSocial.toString().isEmpty) {
        throw Exception('No se encontraron datos del RUC');
      }
      return DniRucResult(
        name: razonSocial.toString().trim(),
        address: direccion.toString().isEmpty ? null : direccion.toString().trim(),
      );
    } else {
      throw Exception('Longitud de documento inválida');
    }
  }
}
