import 'package:virtual_catalog_app/domain/entities/banner_item.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:virtual_catalog_app/domain/entities/payment_method.dart';

class Business {
  final String slug;
  final String ownerId;
  final String name;
  final String description;
  final String logoUrl;
  final String whatsappNumber;
  final List<BannerItem> banners;
  final List<DeliveryMethod> deliveryMethods;
  final List<PaymentMethod> paymentMethods;
  final bool showDesktopLogo;
  final bool showMobileLogo;
  final String? termsAndConditions;
  final List<HomeBlock> homeBlocks;
  final String? izipayUsername;
  final String? izipayPassword;
  final String? izipayPublicKey;
  final String? themeColorHex;
  final String? backgroundColorHex;
  final String? customDomain;

  Business({
    required this.slug,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.whatsappNumber,
    required this.banners,
    required this.deliveryMethods,
    required this.paymentMethods,
    this.showDesktopLogo = true,
    this.showMobileLogo = true,
    this.termsAndConditions,
    this.homeBlocks = const [],
    this.izipayUsername,
    this.izipayPassword,
    this.izipayPublicKey,
    this.themeColorHex,
    this.backgroundColorHex,
    this.customDomain,
  });

  Business copyWith({
    String? slug,
    String? ownerId,
    String? name,
    String? description,
    String? logoUrl,
    String? whatsappNumber,
    List<BannerItem>? banners,
    List<DeliveryMethod>? deliveryMethods,
    List<PaymentMethod>? paymentMethods,
    bool? showDesktopLogo,
    bool? showMobileLogo,
    String? termsAndConditions,
    List<HomeBlock>? homeBlocks,
    String? izipayUsername,
    String? izipayPassword,
    String? izipayPublicKey,
    String? themeColorHex,
    String? backgroundColorHex,
    String? customDomain,
  }) {
    return Business(
      slug: slug ?? this.slug,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      banners: banners ?? this.banners,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      showDesktopLogo: showDesktopLogo ?? this.showDesktopLogo,
      showMobileLogo: showMobileLogo ?? this.showMobileLogo,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      homeBlocks: homeBlocks ?? this.homeBlocks,
      izipayUsername: izipayUsername ?? this.izipayUsername,
      izipayPassword: izipayPassword ?? this.izipayPassword,
      izipayPublicKey: izipayPublicKey ?? this.izipayPublicKey,
      themeColorHex: themeColorHex ?? this.themeColorHex,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      customDomain: customDomain ?? this.customDomain,
    );
  }
}
