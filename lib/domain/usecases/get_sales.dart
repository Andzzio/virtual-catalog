import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/domain/repos/sale_repository.dart';

class GetSales {
  final SaleRepository repository;

  GetSales(this.repository);

  Future<List<Sale>> call(String businessSlug) {
    return repository.getSales(businessSlug);
  }
}
