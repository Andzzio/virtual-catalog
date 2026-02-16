import 'package:virtual_catalog_app/domain/entities/banner_item.dart';

class BannerItemModel {
  final String imageUrl;
  final String title;
  final String subtitle;

  BannerItemModel({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  factory BannerItemModel.fromJson(Map<String, dynamic> json) {
    return BannerItemModel(
      imageUrl: json['imageUrl'],
      title: json['title'],
      subtitle: json['subtitle'],
    );
  }

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'title': title,
    'subtitle': subtitle,
  };

  BannerItem toEntity() =>
      BannerItem(imageUrl: imageUrl, title: title, subtitle: subtitle);

  factory BannerItemModel.fromEntity(BannerItem entity) {
    return BannerItemModel(
      imageUrl: entity.imageUrl,
      title: entity.title,
      subtitle: entity.subtitle,
    );
  }
}
