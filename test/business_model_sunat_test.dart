import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_catalog_app/data/models/business_model.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';

void main() {
  group('BusinessModel SUNAT Fields', () {
    test('BusinessModel can be created with SUNAT fields', () {
      final model = BusinessModel(
        slug: "test-business",
        ownerId: "owner-123",
        name: "Test Business",
        description: "A test business",
        logoUrl: "https://example.com/logo.png",
        whatsappNumber: "51912345678",
        banners: [],
        deliveryMethods: [],
        paymentMethods: [],
        showDesktopLogo: true,
        showMobileLogo: true,
        ruc: "20XXXXXXXXX",
        address: "Jr. Test 123",
        sunatUser: "FACSIS11",
        sunatPassword: "clave123",
        sunatEnvironment: "beta",
        hasCertificate: true,
        certificateExpiresAt: DateTime(2028, 6, 15),
      );

      expect(model.sunatUser, "FACSIS11");
      expect(model.sunatPassword, "clave123");
      expect(model.sunatEnvironment, "beta");
      expect(model.hasCertificate, true);
      expect(model.certificateExpiresAt, DateTime(2028, 6, 15));
    });

    test('BusinessModel.fromJson parses SUNAT fields correctly', () {
      final json = {
        'slug': 'test-business',
        'ownerId': 'owner-123',
        'name': 'Test Business',
        'description': 'A test business',
        'logoUrl': 'https://example.com/logo.png',
        'whatsappNumber': '51912345678',
        'banners': [],
        'deliveryMethods': [],
        'paymentMethods': [],
        'showDesktopLogo': true,
        'showMobileLogo': true,
        'ruc': '20XXXXXXXXX',
        'address': 'Jr. Test 123',
        'sunatUser': 'FACSIS11',
        'sunatPassword': 'clave123',
        'sunatEnvironment': 'beta',
        'hasCertificate': true,
        'certificateExpiresAt': '2028-06-15T00:00:00.000Z',
      };

      final model = BusinessModel.fromJson(json);

      expect(model.sunatUser, "FACSIS11");
      expect(model.sunatPassword, "clave123");
      expect(model.sunatEnvironment, "beta");
      expect(model.hasCertificate, true);
      expect(model.certificateExpiresAt, isNotNull);
      expect(model.certificateExpiresAt?.year, 2028);
      expect(model.certificateExpiresAt?.month, 6);
    });

    test('BusinessModel.toJson preserves SUNAT fields', () {
      final model = BusinessModel(
        slug: "test-business",
        ownerId: "owner-123",
        name: "Test Business",
        description: "A test business",
        logoUrl: "https://example.com/logo.png",
        whatsappNumber: "51912345678",
        banners: [],
        deliveryMethods: [],
        paymentMethods: [],
        showDesktopLogo: true,
        showMobileLogo: true,
        ruc: "20XXXXXXXXX",
        address: "Jr. Test 123",
        sunatUser: "FACSIS11",
        sunatPassword: "clave123",
        sunatEnvironment: "prod",
        hasCertificate: true,
        certificateExpiresAt: DateTime(2028, 6, 15),
      );

      final json = model.toJson();

      expect(json['sunatUser'], "FACSIS11");
      expect(json['sunatPassword'], "clave123");
      expect(json['sunatEnvironment'], "prod");
      expect(json['hasCertificate'], true);
      expect(json['certificateExpiresAt'], isNotNull);
    });

    test('Business entity converts to/from BusinessModel with SUNAT fields', () {
      final expiresAt = DateTime(2028, 6, 15);
      final entity = Business(
        slug: "test-business",
        ownerId: "owner-123",
        name: "Test Business",
        description: "A test business",
        logoUrl: "https://example.com/logo.png",
        whatsappNumber: "51912345678",
        banners: [],
        deliveryMethods: [],
        paymentMethods: [],
        showDesktopLogo: true,
        showMobileLogo: true,
        ruc: "20XXXXXXXXX",
        address: "Jr. Test 123",
        sunatUser: "FACSIS11",
        sunatPassword: "clave123",
        sunatEnvironment: "beta",
        hasCertificate: true,
        certificateExpiresAt: expiresAt,
      );

      final model = BusinessModel.fromEntity(entity);
      final convertedEntity = model.toEntity();

      expect(convertedEntity.sunatUser, entity.sunatUser);
      expect(convertedEntity.sunatPassword, entity.sunatPassword);
      expect(convertedEntity.sunatEnvironment, entity.sunatEnvironment);
      expect(convertedEntity.hasCertificate, entity.hasCertificate);
      expect(convertedEntity.certificateExpiresAt, entity.certificateExpiresAt);
    });

    test('SUNAT fields are optional and null by default', () {
      final model = BusinessModel(
        slug: "test-business",
        ownerId: "owner-123",
        name: "Test Business",
        description: "A test business",
        logoUrl: "https://example.com/logo.png",
        whatsappNumber: "51912345678",
        banners: [],
        deliveryMethods: [],
        paymentMethods: [],
        showDesktopLogo: true,
        showMobileLogo: true,
      );

      expect(model.sunatUser, isNull);
      expect(model.sunatPassword, isNull);
      expect(model.sunatEnvironment, isNull);
      expect(model.hasCertificate, isNull);
      expect(model.certificateExpiresAt, isNull);
    });

    test('copyWith preserves SUNAT fields', () {
      final original = BusinessModel(
        slug: "test-business",
        ownerId: "owner-123",
        name: "Test Business",
        description: "A test business",
        logoUrl: "https://example.com/logo.png",
        whatsappNumber: "51912345678",
        banners: [],
        deliveryMethods: [],
        paymentMethods: [],
        showDesktopLogo: true,
        showMobileLogo: true,
        ruc: "20XXXXXXXXX",
        sunatUser: "FACSIS11",
        sunatPassword: "clave123",
        sunatEnvironment: "beta",
        hasCertificate: true,
        certificateExpiresAt: DateTime(2028, 6, 15),
      );

      // Convert to entity to use copyWith
      final entity = original.toEntity();
      final updated = entity.copyWith(
        sunatUser: "FACSIS12",
        sunatEnvironment: "prod",
      );

      expect(updated.sunatUser, "FACSIS12");
      expect(updated.sunatPassword, "clave123"); // Should remain same
      expect(updated.sunatEnvironment, "prod");
      expect(updated.hasCertificate, true); // Should remain same
    });
  });
}
