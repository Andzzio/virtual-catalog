import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:virtual_catalog_app/data/models/user_model.dart';
import 'package:virtual_catalog_app/domain/datasources/user_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/user_entity.dart';

class UserDatasourceImpl implements UserDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Dio _dio = Dio();

  String _getFunctionUrl(String functionName) {
    final uploadCertUrl = dotenv.env['FUNCTION_UPLOAD_CERTIFICATE'] ?? '';
    if (uploadCertUrl.isNotEmpty) {
      final suffixIndex = uploadCertUrl.indexOf('upload-certificate');
      if (suffixIndex != -1) {
        final suffix = uploadCertUrl.substring(suffixIndex + 'upload-certificate'.length);
        final cleanName = functionName.replaceAll('_', '-');
        return uploadCertUrl.substring(0, suffixIndex) + cleanName + suffix;
      }
    }
    final cleanName = functionName.replaceAll('_', '-');
    return "https://$cleanName-pgwhr3k6mq-uc.a.run.app";
  }

  @override
  Future<List<UserEntity>> getUsers(String businessSlug) async {
    final snapshot = await _db
        .collection("users")
        .where("businessId", isEqualTo: businessSlug)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> createUser({
    required String businessSlug,
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = _getFunctionUrl("register_user");
    final response = await _dio.post(url, data: {
      "email": email,
      "password": password,
      "name": name,
      "role": role,
      "businessId": businessSlug,
    });
    if (response.statusCode != 200 || response.data["success"] != true) {
      throw Exception(response.data["error"] ?? "Error al crear usuario");
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    final url = _getFunctionUrl("delete_user");
    final response = await _dio.post(url, data: {
      "userId": userId,
    });
    if (response.statusCode != 200 || response.data["success"] != true) {
      throw Exception(response.data["error"] ?? "Error al eliminar usuario");
    }
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    final url = _getFunctionUrl("update_user_role");
    final response = await _dio.post(url, data: {
      "userId": userId,
      "role": role,
    });
    if (response.statusCode != 200 || response.data["success"] != true) {
      throw Exception(response.data["error"] ?? "Error al actualizar rol");
    }
  }
}
