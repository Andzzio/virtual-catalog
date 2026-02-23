import 'package:virtual_catalog_app/data/models/banner_item_model.dart';
import 'package:virtual_catalog_app/data/models/delivery_method_model.dart';
import 'package:virtual_catalog_app/data/models/payment_method_model.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';

class BusinessModel {
  final String slug;
  final String name;
  final String description;
  final String logoUrl;
  final String whatsappNumber;
  final List<BannerItemModel> banners;
  final List<DeliveryMethodModel> deliveryMethods;
  final List<PaymentMethodModel> paymentMethods;

  BusinessModel({
    required this.slug,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.whatsappNumber,
    required this.banners,
    required this.deliveryMethods,
    required this.paymentMethods,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      whatsappNumber: json['whatsappNumber'],
      banners: (json['banners'] as List)
          .map((b) => BannerItemModel.fromJson(b))
          .toList(),
      deliveryMethods: (json["deliveryMethods"] as List)
          .map((d) => DeliveryMethodModel.fromJson(d))
          .toList(),
      paymentMethods: (json["paymentMethods"] as List)
          .map((p) => PaymentMethodModel.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'name': name,
    'description': description,
    'logoUrl': logoUrl,
    'whatsappNumber': whatsappNumber,
    'banners': banners.map((b) => b.toJson()).toList(),
    "deliveryMethods": deliveryMethods.map((d) => d.toJson()).toList(),
    "paymentMethods": paymentMethods.map((p) => p.toJson()).toList(),
  };

  Business toEntity() => Business(
    slug: slug,
    name: name,
    description: description,
    logoUrl: logoUrl,
    whatsappNumber: whatsappNumber,
    banners: banners.map((b) => b.toEntity()).toList(),
    deliveryMethods: deliveryMethods.map((d) => d.toEntity()).toList(),
    paymentMethods: paymentMethods.map((p) => p.toEntity()).toList(),
  );

  factory BusinessModel.fromEntity(Business entity) {
    return BusinessModel(
      slug: entity.slug,
      name: entity.name,
      description: entity.description,
      logoUrl: entity.logoUrl,
      whatsappNumber: entity.whatsappNumber,
      banners: entity.banners
          .map((b) => BannerItemModel.fromEntity(b))
          .toList(),
      deliveryMethods: entity.deliveryMethods
          .map((d) => DeliveryMethodModel.fromEntity(d))
          .toList(),
      paymentMethods: entity.paymentMethods
          .map((p) => PaymentMethodModel.fromEntity(p))
          .toList(),
    );
  }
}
