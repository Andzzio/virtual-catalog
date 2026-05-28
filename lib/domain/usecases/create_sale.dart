import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/domain/repos/sale_repository.dart';

class CreateSale {
  final SaleRepository repository;

  CreateSale(this.repository);

  Future<Sale> call(String businessSlug, Sale sale) {
    return repository.createSale(businessSlug, sale);
  }
}
