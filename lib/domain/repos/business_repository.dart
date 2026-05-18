import 'package:virtual_catalog_app/domain/entities/business.dart';

abstract class BusinessRepository {
  Future<Business?> getBusinessBySlug(String slug);
  Future<Business?> getBusinessByDomain(String domain);
  Future<void> updateBusiness(String slug, Business business);
}
