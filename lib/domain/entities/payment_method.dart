import 'package:virtual_catalog_app/domain/entities/payment_type.dart';

class PaymentMethod {
  final String name;
  final String? description;
  final PaymentType type;

  PaymentMethod({required this.name, this.description, required this.type});
}
