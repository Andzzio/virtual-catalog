import 'dart:typed_data';
import 'package:dio/dio.dart';

class CloudinaryService {
  static const String _cloudName = "doj9jse8d";
  static const String _uploadPreset = "virtual_catalog";

  final Dio _dio = Dio();

  Future<Map<String, String>> uploadImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(imageBytes, filename: fileName),
      "upload_preset": _uploadPreset,
    });
    final response = await _dio.post(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      data: formData,
    );
    return {
      "url": response.data["secure_url"],
      "publicId": response.data["public_id"],
    };
  }

  Future<List<Map<String, String>>> uploadMultipleImages(
    List<Uint8List> imagesBytes,
    List<String> fileNames,
  ) async {
    final results = <Map<String, String>>[];

    for (int i = 0; i < imagesBytes.length; i++) {
      final result = await (uploadImage(imagesBytes[i], fileNames[i]));
      results.add(result);
    }
    return results;
  }
}
