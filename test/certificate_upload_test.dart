import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:virtual_catalog_app/data/services/certificate_upload_service.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';

class MockInterceptorAdapter extends Interceptor {
  final MockResponse Function(RequestOptions) handler;

  MockInterceptorAdapter(this.handler);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final mock = this.handler(options);
    handler.resolve(Response(
      requestOptions: options,
      statusCode: mock.statusCode,
      data: mock.data,
    ));
  }
}

class MockResponse {
  final int statusCode;
  final Map<String, dynamic> data;
  MockResponse({required this.statusCode, required this.data});
}

void main() {
  late CertificateUploadService service;
  late Business testBusiness;
  late Uint8List fakePfxBytes;

  setUpAll(() async {
    await dotenv.load(fileName: "env");
  });

  setUp(() {
    testBusiness = Business(
      slug: "test-business",
      ownerId: "owner-123",
      name: "Test SAC",
      description: "",
      logoUrl: "",
      whatsappNumber: "51999999999",
      banners: [],
      deliveryMethods: [],
      paymentMethods: [],
      ruc: "20123456789",
      sunatUser: "MODDATOS",
      sunatPassword: "MODDATOS",
      sunatPfxPassword: "MODDATOS",
      sunatEnvironment: "beta",
    );

    fakePfxBytes = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

    service = CertificateUploadService(dio: Dio());
  });

  group('CertificateUploadService - upload()', () {
    test('retorna success con expiresAt cuando server responde 200 OK', () async {
      service = CertificateUploadService(
        dio: _buildDioWithMock((options) {
          expect(options.data["ruc"], "20123456789");
          expect(options.data["pfxBase64"], isNotEmpty);
          expect(options.data["password"], "MODDATOS");
          expect(options.data["environment"], "beta");

          return MockResponse(
            statusCode: 200,
            data: {
              "success": true,
              "expiresAt": "2028-06-15T10:30:00",
              "commonName": "CN=TEST SAC",
              "secretId": "cert-20123456789-beta",
            },
          );
        }),
      );

      final result = await service.upload(
        business: testBusiness,
        pfxBytes: fakePfxBytes,
        pfxPassword: "MODDATOS",
        environment: "beta",
      );

      expect(result.success, isTrue);
      expect(result.expiresAt, isNotNull);
      expect(result.expiresAt!.year, 2028);
      expect(result.expiresAt!.month, 6);
      expect(result.error, isNull);
    });

    test('retorna error cuando server responde 400 con mensaje', () async {
      service = CertificateUploadService(
        dio: _buildDioWithMock((options) {
          return MockResponse(
            statusCode: 400,
            data: {
              "success": false,
              "error": "Certificado inválido: password incorrecta",
            },
          );
        }),
      );

      final result = await service.upload(
        business: testBusiness,
        pfxBytes: fakePfxBytes,
        pfxPassword: "wrong",
        environment: "beta",
      );

      expect(result.success, isFalse);
      expect(result.error, contains("password incorrecta"));
      expect(result.expiresAt, isNull);
    });

    test('retorna error cuando server responde 500', () async {
      service = CertificateUploadService(
        dio: _buildDioWithMock((options) {
          return MockResponse(
            statusCode: 500,
            data: {"error": "Internal server error"},
          );
        }),
      );

      final result = await service.upload(
        business: testBusiness,
        pfxBytes: fakePfxBytes,
        pfxPassword: "MODDATOS",
        environment: "beta",
      );

      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });

    test('manda RUC vacío si business no tiene RUC', () async {
      final businessSinRuc = Business(
        slug: "test",
        ownerId: "1",
        name: "Test",
        description: "",
        logoUrl: "",
        whatsappNumber: "51999999999",
        banners: [],
        deliveryMethods: [],
        paymentMethods: [],
      );

      service = CertificateUploadService(
        dio: _buildDioWithMock((options) {
          expect(options.data["ruc"], "");
          return MockResponse(
            statusCode: 400,
            data: {"success": false, "error": "RUC es requerido"},
          );
        }),
      );

      final result = await service.upload(
        business: businessSinRuc,
        pfxBytes: fakePfxBytes,
        pfxPassword: "MODDATOS",
        environment: "beta",
      );

      expect(result.success, isFalse);
    });

    test('funciona con ambiente prod y RUC diferente', () async {
      final businessProd = Business(
        slug: "test",
        ownerId: "1",
        name: "Test Prod",
        description: "",
        logoUrl: "",
        whatsappNumber: "51999999999",
        banners: [],
        deliveryMethods: [],
        paymentMethods: [],
        ruc: "20987654321",
        sunatUser: "FACSIS11",
        sunatPassword: "realpass",
        sunatPfxPassword: "realpfxpass",
        sunatEnvironment: "prod",
      );

      service = CertificateUploadService(
        dio: _buildDioWithMock((options) {
          expect(options.data["environment"], "prod");
          expect(options.data["ruc"], "20987654321");
          expect(options.data["password"], "realpfxpass");
          return MockResponse(
            statusCode: 200,
            data: {
              "success": true,
              "expiresAt": "2027-12-31T23:59:59",
              "commonName": "CN=TEST PROD SAC",
              "secretId": "cert-20987654321-prod",
            },
          );
        }),
      );

      final result = await service.upload(
        business: businessProd,
        pfxBytes: fakePfxBytes,
        pfxPassword: "realpfxpass",
        environment: "prod",
      );

      expect(result.success, isTrue);
      expect(result.expiresAt!.year, 2027);
    });

    test('codifica el .pfx en base64 correctamente', () async {
      final specificBytes = Uint8List.fromList(
        [72, 101, 108, 108, 111], // "Hello"
      );
      final expectedBase64 = base64Encode(specificBytes);

      service = CertificateUploadService(
        dio: _buildDioWithMock((options) {
          expect(options.data["pfxBase64"], expectedBase64);
          expect(
            base64Decode(options.data["pfxBase64"] as String),
            [72, 101, 108, 108, 111],
          );
          return MockResponse(
            statusCode: 200,
            data: {"success": true, "expiresAt": "2028-01-01T00:00:00"},
          );
        }),
      );

      final result = await service.upload(
        business: testBusiness,
        pfxBytes: specificBytes,
        pfxPassword: "MODDATOS",
        environment: "beta",
      );

      expect(result.success, isTrue);
    });

    test('usa la URL del archivo env', () async {
      final envUrl = dotenv.env['FUNCTION_UPLOAD_CERTIFICATE'];
      expect(envUrl, isNotNull);
      expect(envUrl!.contains("upload-certificate"), isTrue);
    });
  });
}

Dio _buildDioWithMock(MockResponse Function(RequestOptions) handler) {
  final dio = Dio();
  dio.interceptors.add(MockInterceptorAdapter(handler));
  return dio;
}
