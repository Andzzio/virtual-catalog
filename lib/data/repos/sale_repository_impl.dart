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
  Future<Sale> createSale(String businessSlug, Sale sale) {
    return datasource.createSale(businessSlug, sale);
  }

  @override
  Future<void> updateSaleSunatStatus(
    String businessSlug,
    String saleId, {
    required String status,
    String? description,
    String? hash,
    String? pdfUrl,
    String? xmlUrl,
    String? cdrUrl,
  }) {
    return datasource.updateSaleSunatStatus(
      businessSlug,
      saleId,
      status: status,
      description: description,
      hash: hash,
      pdfUrl: pdfUrl,
      xmlUrl: xmlUrl,
      cdrUrl: cdrUrl,
    );
  }
}
