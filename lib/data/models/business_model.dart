import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/banner_item_model.dart';
import 'package:virtual_catalog_app/data/models/delivery_method_model.dart';
import 'package:virtual_catalog_app/data/models/payment_method_model.dart';
import 'package:virtual_catalog_app/data/models/home_block_model.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';

class BusinessModel {
  final String slug;
  final String ownerId;
  final String name;
  final String description;
  final String logoUrl;
  final String whatsappNumber;
  final List<BannerItemModel> banners;
  final List<DeliveryMethodModel> deliveryMethods;
  final List<PaymentMethodModel> paymentMethods;
  final bool showDesktopLogo;
  final bool showMobileLogo;
  final String? termsAndConditions;
  final List<HomeBlockModel> homeBlocks;

  BusinessModel({
    required this.slug,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.whatsappNumber,
    required this.banners,
    required this.deliveryMethods,
    required this.paymentMethods,
    required this.showDesktopLogo,
    required this.showMobileLogo,
    this.termsAndConditions,
    this.homeBlocks = const [],
  });

  factory BusinessModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return BusinessModel(
      slug: doc.id,
      ownerId: json["ownerId"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      logoUrl: json["logoUrl"] ?? "",
      whatsappNumber: json["whatsappNumber"] ?? "",
      banners: (json["banners"] as List? ?? [])
          .map((b) => BannerItemModel.fromJson(b as Map<String, dynamic>))
          .toList(),
      deliveryMethods: (json["deliveryMethods"] as List? ?? [])
          .map((d) => DeliveryMethodModel.fromJson(d as Map<String, dynamic>))
          .toList(),
      paymentMethods: (json["paymentMethods"] as List? ?? [])
          .map((p) => PaymentMethodModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      showDesktopLogo: json['showDesktopLogo'] ?? true,
      showMobileLogo: json['showMobileLogo'] ?? true,
      termsAndConditions: json['termsAndConditions'],
      homeBlocks: (json['homeBlocks'] as List? ?? [])
          .map((b) => HomeBlockModel.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      slug: json['slug'] ?? "",
      ownerId: json['ownerId'] ?? "",
      name: json['name'] ?? "",
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
      showDesktopLogo: json['showDesktopLogo'] ?? true,
      showMobileLogo: json['showMobileLogo'] ?? true,
      termsAndConditions: json['termsAndConditions'],
      homeBlocks: (json['homeBlocks'] as List? ?? [])
          .map((b) => HomeBlockModel.fromJson(b))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'ownerId': ownerId,
    'name': name,
    'description': description,
    'logoUrl': logoUrl,
    'whatsappNumber': whatsappNumber,
    'banners': banners.map((b) => b.toJson()).toList(),
    "deliveryMethods": deliveryMethods.map((d) => d.toJson()).toList(),
    "paymentMethods": paymentMethods.map((p) => p.toJson()).toList(),
    "showDesktopLogo": showDesktopLogo,
    "showMobileLogo": showMobileLogo,
    "termsAndConditions": termsAndConditions,
    "homeBlocks": homeBlocks.map((b) => b.toJson()).toList(),
  };

  Business toEntity() => Business(
    slug: slug,
    ownerId: ownerId,
    name: name,
    description: description,
    logoUrl: logoUrl,
    whatsappNumber: whatsappNumber,
    banners: banners.map((b) => b.toEntity()).toList(),
    deliveryMethods: deliveryMethods.map((d) => d.toEntity()).toList(),
    paymentMethods: paymentMethods.map((p) => p.toEntity()).toList(),
    showDesktopLogo: showDesktopLogo,
    showMobileLogo: showMobileLogo,
    termsAndConditions: termsAndConditions,
    homeBlocks: homeBlocks.map((b) => b.toEntity()).toList(),
  );

  factory BusinessModel.fromEntity(Business entity) {
    return BusinessModel(
      slug: entity.slug,
      ownerId: entity.ownerId,
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
      showDesktopLogo: entity.showDesktopLogo,
      showMobileLogo: entity.showMobileLogo,
      termsAndConditions: entity.termsAndConditions,
      homeBlocks: entity.homeBlocks
          .map((b) => HomeBlockModel.fromEntity(b))
          .toList(),
    );
  }
}
