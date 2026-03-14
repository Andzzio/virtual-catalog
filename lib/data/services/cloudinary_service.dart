import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

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
    return Future.wait(
      List.generate(
        imagesBytes.length,
        (i) => uploadImage(imagesBytes[i], fileNames[i]),
      ),
    );
  }
}
