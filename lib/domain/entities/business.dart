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
  });
}
