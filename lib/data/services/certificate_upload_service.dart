import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';

class CertificateUploadResult {
  final bool success;
  final DateTime? expiresAt;
  final String? error;

  CertificateUploadResult({
    required this.success,
    this.expiresAt,
    this.error,
  });
}

class CertificateUploadService {
  final Dio _dio;

  CertificateUploadService({Dio? dio}) : _dio = dio ?? Dio();

  Future<CertificateUploadResult> upload({
    required Business business,
    required Uint8List pfxBytes,
    required String pfxPassword,
    required String environment,
  }) async {
    try {
      final functionUrl = dotenv.env['FUNCTION_UPLOAD_CERTIFICATE'] ??
          "https://us-central1-catalogo-virtual-app.cloudfunctions.net/upload_certificate";

      final response = await _dio.post(functionUrl, data: {
        "ruc": business.ruc ?? "",
        "pfxBase64": base64Encode(pfxBytes),
        "password": pfxPassword,
        "environment": environment,
      });

      if (response.statusCode == 200 && response.data["success"] == true) {
        return CertificateUploadResult(
          success: true,
          expiresAt: DateTime.parse(response.data["expiresAt"] as String),
        );
      }

      return CertificateUploadResult(
        success: false,
        error: response.data["error"] ?? "Error desconocido al subir certificado",
      );
    } catch (e) {
      return CertificateUploadResult(
        success: false,
        error: "Error de conexión: $e",
      );
    }
  }

  Future<Uint8List?> pickPfxFile() async {
    try {
      final result = await _pickFile();
      if (result == null || result.isEmpty) return null;
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _pickFile() async {
    // En tests, se mockea este método
    throw UnimplementedError("Usar FilePicker.platform.pickFiles en producción");
  }
}
