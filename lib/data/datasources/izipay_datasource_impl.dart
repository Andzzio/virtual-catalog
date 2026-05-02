import 'package:dio/dio.dart';
import 'package:virtual_catalog_app/domain/datasources/izipay_datasource.dart';

class IzipayDatasourceImpl implements IzipayDataSource {
  final Dio dio;

  IzipayDatasourceImpl({required this.dio});

  @override
  Future<String> createPaymentLink({
    required double amount,
    required String orderId,
    required String businessId,
    String? customerEmail,
  }) async {
    try {
      const String functionUrl =
          "https://us-central1-catalogo-virtual-app.cloudfunctions.net/create_izipay_payment";
      final response = await dio.post(
        functionUrl,
        data: {
          "amount": amount,
          "orderId": orderId,
          "businessId": businessId,
          if (customerEmail != null) "customerEmail": customerEmail,
        },
      );

      if (response.statusCode == 200) {
        return response.data["paymentUrl"];
      } else {
        throw Exception("Error al crear el pago ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Error del backend: ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }
}
