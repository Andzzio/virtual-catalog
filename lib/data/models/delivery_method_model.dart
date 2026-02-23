import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_type.dart';

class DeliveryMethodModel {
  final String name;
  final String type;
  final int price;
  final String? description;

  DeliveryMethodModel({
    required this.name,
    required this.type,
    required this.price,
    this.description,
  });
  factory DeliveryMethodModel.fromJson(Map<String, dynamic> json) {
    return DeliveryMethodModel(
      name: json['name'],
      type: json['type'],
      price: json['price'],
      description: json['description'],
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'price': price,
    'description': description,
  };
  DeliveryMethod toEntity() => DeliveryMethod(
    name: name,
    type: DeliveryType.values.byName(type),
    price: price,
    description: description,
  );
  factory DeliveryMethodModel.fromEntity(DeliveryMethod entity) {
    return DeliveryMethodModel(
      name: entity.name,
      type: entity.type.name,
      price: entity.price,
      description: entity.description,
    );
  }
}
