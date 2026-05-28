import 'package:virtual_catalog_app/domain/entities/sale.dart';

abstract class SaleDatasource {
  Future<List<Sale>> getSales(String businessSlug);
  Future<Sale> createSale(String businessSlug, Sale sale);
  Future<void> updateSaleSunatStatus(
    String businessSlug,
    String saleId, {
    required String status,
    String? description,
    String? hash,
    String? pdfUrl,
    String? xmlUrl,
    String? cdrUrl,
  });
}
