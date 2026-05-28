import 'package:virtual_catalog_app/domain/repos/sale_repository.dart';

class UpdateSaleSunatStatus {
  final SaleRepository repository;

  UpdateSaleSunatStatus(this.repository);

  Future<void> call(
    String businessSlug,
    String saleId, {
    required String status,
    String? description,
    String? hash,
    String? pdfUrl,
    String? xmlUrl,
    String? cdrUrl,
  }) {
    return repository.updateSaleSunatStatus(
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
