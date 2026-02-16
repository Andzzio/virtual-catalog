import 'package:virtual_catalog_app/domain/datasources/business_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/repos/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessDatasource datasource;

  BusinessRepositoryImpl({required this.datasource});

  @override
  Future<Business?> getBusinessBySlug(String slug) {
    return datasource.getBusinessBySlug(slug);
  }
}
