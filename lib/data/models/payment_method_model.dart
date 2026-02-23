import 'package:virtual_catalog_app/domain/entities/payment_method.dart';
import 'package:virtual_catalog_app/domain/entities/payment_type.dart';

class PaymentMethodModel {
  final String name;
  final String type;
  final String? description;

  PaymentMethodModel({
    required this.name,
    required this.type,
    this.description,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      name: json['name'],
      type: json['type'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'description': description,
  };

  PaymentMethod toEntity() => PaymentMethod(
    name: name,
    type: PaymentType.values.byName(type),
    description: description,
  );

  factory PaymentMethodModel.fromEntity(PaymentMethod entity) {
    return PaymentMethodModel(
      name: entity.name,
      type: entity.type.name,
      description: entity.description,
    );
  }
}
