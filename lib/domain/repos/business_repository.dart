import 'package:virtual_catalog_app/domain/entities/business.dart';

abstract class BusinessRepository {
  Future<Business?> getBusinessBySlug(String slug);
}
