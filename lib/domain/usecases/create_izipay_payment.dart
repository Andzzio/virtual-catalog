import 'package:virtual_catalog_app/domain/repos/izipay_repository.dart';

class CreateIzipayPaymentUseCase {
  final IzipayRepository repository;

  CreateIzipayPaymentUseCase(this.repository);

  Future<String> call({
    required double amount,
    required String orderId,
    required String businessId,
    String? customerEmail,
  }) {
    return repository.createPaymentLink(
      amount: amount,
      orderId: orderId,
      businessId: businessId,
      customerEmail: customerEmail,
    );
  }
}
