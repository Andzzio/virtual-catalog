import 'package:virtual_catalog_app/domain/entities/banner_item.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';

class Business {
  final String slug;
  final String name;
  final String description;
  final String logoUrl;
  final String whatsappNumber;
  final List<BannerItem> banners;
  final List<DeliveryMethod> deliveryMethods;

  Business({
    required this.slug,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.whatsappNumber,
    required this.banners,
    required this.deliveryMethods,
  });
}
