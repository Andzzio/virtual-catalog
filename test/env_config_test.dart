import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Env file - Cloud Function URLs', () {
    setUpAll(() async {
      await dotenv.load(fileName: "env");
    });

    test('FUNCTION_UPLOAD_CERTIFICATE exists and is a valid URL', () {
      final url = dotenv.env['FUNCTION_UPLOAD_CERTIFICATE'];
      expect(url, isNotNull, reason: "FUNCTION_UPLOAD_CERTIFICATE no está en env");
      expect(url, isNotEmpty, reason: "FUNCTION_UPLOAD_CERTIFICATE está vacío");
      expect(Uri.tryParse(url!), isNotNull, reason: "No es una URL válida");
      expect(url.startsWith("https://"), isTrue, reason: "Debe ser HTTPS");
    });

    test('FUNCTION_EMIT_TO_SUNAT exists and is a valid URL', () {
      final url = dotenv.env['FUNCTION_EMIT_TO_SUNAT'];
      expect(url, isNotNull, reason: "FUNCTION_EMIT_TO_SUNAT no está en env");
      expect(url, isNotEmpty, reason: "FUNCTION_EMIT_TO_SUNAT está vacío");
      expect(Uri.tryParse(url!), isNotNull, reason: "No es una URL válida");
      expect(url.startsWith("https://"), isTrue, reason: "Debe ser HTTPS");
    });

    test('Ambas URLs apuntan al servicio de Cloud Run correcto', () {
      final uploadUrl = dotenv.env['FUNCTION_UPLOAD_CERTIFICATE']!;
      final emitUrl = dotenv.env['FUNCTION_EMIT_TO_SUNAT']!;

      expect(uploadUrl.contains("pgwhr3k6mq-uc.a.run.app"), isTrue,
          reason: "URL de upload no apunta al servicio de Cloud Run correcto");
      expect(emitUrl.contains("pgwhr3k6mq-uc.a.run.app"), isTrue,
          reason: "URL de emit no apunta al servicio de Cloud Run correcto");
    });

    test('CLOUDINARY_CLOUD_NAME se mantiene del env original', () {
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      expect(cloudName, isNotNull);
      expect(cloudName, isNotEmpty);
    });

    test('Las URLs de Cloud Functions son diferentes entre sí', () {
      final uploadUrl = dotenv.env['FUNCTION_UPLOAD_CERTIFICATE']!;
      final emitUrl = dotenv.env['FUNCTION_EMIT_TO_SUNAT']!;
      expect(uploadUrl, isNot(equals(emitUrl)),
          reason: "upload_certificate y emit_to_sunat no deberían tener la misma URL");
    });
  });
}
