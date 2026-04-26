import 'package:virtual_catalog_app/domain/entities/home_block.dart';

class HomeBlockModel {
  final String id;
  final String layout;
  final String title;
  final String? subtitle;
  final bool showButton;
  final String? buttonText;
  final String? buttonAction;
  final String sortCriteria;
  final int itemsLimit;
  final String? specificProductId;

  HomeBlockModel({
    required this.id,
    required this.layout,
    required this.title,
    this.subtitle,
    required this.showButton,
    this.buttonText,
    this.buttonAction,
    required this.sortCriteria,
    required this.itemsLimit,
    this.specificProductId,
  });

  factory HomeBlockModel.fromJson(Map<String, dynamic> json) {
    return HomeBlockModel(
      id: json['id'] ?? '',
      layout: json['layout'] ?? 'list',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      showButton: json['showButton'] ?? false,
      buttonText: json['buttonText'],
      buttonAction: json['buttonAction'],
      sortCriteria: json['sortCriteria'] ?? 'newest',
      itemsLimit: json['itemsLimit'] ?? 10,
      specificProductId: json['specificProductId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'layout': layout,
    'title': title,
    'subtitle': subtitle,
    'showButton': showButton,
    'buttonText': buttonText,
    'buttonAction': buttonAction,
    'sortCriteria': sortCriteria,
    'itemsLimit': itemsLimit,
    'specificProductId': specificProductId,
  };

  HomeBlock toEntity() {
    return HomeBlock(
      id: id,
      layout: BlockLayout.values.firstWhere(
        (e) => e.name == layout,
        orElse: () => BlockLayout.list,
      ),
      title: title,
      subtitle: subtitle,
      showButton: showButton,
      buttonText: buttonText,
      buttonAction: buttonAction,
      sortCriteria: BlockSortCriteria.values.firstWhere(
        (e) => e.name == sortCriteria,
        orElse: () => BlockSortCriteria.newest,
      ),
      itemsLimit: itemsLimit,
      specificProductId: specificProductId,
    );
  }

  factory HomeBlockModel.fromEntity(HomeBlock entity) {
    return HomeBlockModel(
      id: entity.id,
      layout: entity.layout.name,
      title: entity.title,
      subtitle: entity.subtitle,
      showButton: entity.showButton,
      buttonText: entity.buttonText,
      buttonAction: entity.buttonAction,
      sortCriteria: entity.sortCriteria.name,
      itemsLimit: entity.itemsLimit,
      specificProductId: entity.specificProductId,
    );
  }
}
