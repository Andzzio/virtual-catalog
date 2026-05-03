import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/usecases/create_izipay_payment.dart';

class IzipayProvider extends ChangeNotifier {
  final CreateIzipayPaymentUseCase createIzipayPaymentUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  IzipayProvider({required this.createIzipayPaymentUseCase});

  Future<String?> createPaymentLink({
    required double amount,
    required String orderId,
    required String businessId,
    String? customerEmail,
    String? customerName,
    String? customerLastName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final paymentUrl = await createIzipayPaymentUseCase.call(
        amount: amount,
        orderId: orderId,
        businessId: businessId,
        customerEmail: customerEmail,
        customerName: customerName,
        customerLastName: customerLastName,
      );
      _isLoading = false;
      notifyListeners();
      return paymentUrl;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error al crear el pago: $e");
      return null;
    }
  }
}
