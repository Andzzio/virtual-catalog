import 'package:virtual_catalog_app/domain/datasources/sale_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/domain/repos/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleDatasource datasource;

  SaleRepositoryImpl({required this.datasource});

  @override
  Future<List<Sale>> getSales(String businessSlug) {
    return datasource.getSales(businessSlug);
  }

  @override
  Future<void> createSale(String businessSlug, Sale sale) {
    return datasource.createSale(businessSlug, sale);
  }
}
