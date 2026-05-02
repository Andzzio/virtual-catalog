abstract class IzipayRepository {
  Future<String> createPaymentLink({
    required double amount,
    required String orderId,
    required String businessId,
    String? customerEmail,
  });
}
