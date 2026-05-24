import 'package:virtual_catalog_app/domain/entities/sale.dart';

abstract class SaleDatasource {
  Future<List<Sale>> getSales(String businessSlug);
  Future<void> createSale(String businessSlug, Sale sale);
}
