import 'package:virtual_catalog_app/domain/datasources/izipay_datasource.dart';
import 'package:virtual_catalog_app/domain/repos/izipay_repository.dart';

class IzipayRepositoryImpl implements IzipayRepository {
  final IzipayDataSource izipayDataSource;

  IzipayRepositoryImpl({required this.izipayDataSource});

  @override
  Future<String> createPaymentLink({
    required double amount,
    required String orderId,
    required String businessId,
  }) {
    return izipayDataSource.createPaymentLink(
      amount: amount,
      orderId: orderId,
      businessId: businessId,
    );
  }
}
