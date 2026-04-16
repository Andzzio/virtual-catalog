import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CloudinaryService {
  final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  final Dio _dio = Dio();

  Future<Map<String, String>> uploadImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final Uint8List imageBytesCompressed = await _compressImage(imageBytes);

    final formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(imageBytesCompressed, filename: fileName),
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

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    final Uint8List imageCompressed =
        await FlutterImageCompress.compressWithList(
          imageBytes,
          minWidth: 1920,
          quality: 80,
          format: CompressFormat.webp,
        );

    return imageCompressed;
  }
}
