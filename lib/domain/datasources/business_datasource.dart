import 'package:virtual_catalog_app/domain/entities/business.dart';

abstract class BusinessDatasource {
  Future<Business?> getBusinessBySlug(String slug);
}
