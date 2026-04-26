enum BlockLayout {
  list,
  grid,
  mosaic,
  featured,
}

enum BlockSortCriteria {
  bestSelling,
  newest,
  recentlyUpdated,
  alphabetical,
  biggestDiscount,
  premiumFirst,
  affordableFirst,
  manual,
}

class HomeBlock {
  final String id;
  final BlockLayout layout;
  final String title;
  final String? subtitle;
  final bool showButton;
  final String? buttonText;
  final String? buttonAction;
  final BlockSortCriteria sortCriteria;
  final int itemsLimit;
  final String? specificProductId;

  HomeBlock({
    required this.id,
    required this.layout,
    required this.title,
    this.subtitle,
    this.showButton = false,
    this.buttonText,
    this.buttonAction,
    required this.sortCriteria,
    required this.itemsLimit,
    this.specificProductId,
  });
}
