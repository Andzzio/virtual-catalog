import 'package:virtual_catalog_app/domain/entities/delivery_type.dart';

class DeliveryMethod {
  final String name;
  final DeliveryType type;
  final int price;
  final String? description;

  DeliveryMethod({
    required this.name,
    required this.type,
    required this.price,
    this.description,
  });
}
