class ProductVariant {
  final String name;
  final int? color;
  final int stock;
  final List<String> sizes;
  final double? specificPrice;

  ProductVariant({
    required this.name,
    this.color,
    this.specificPrice,
    required this.stock,
    required this.sizes,
  });
}
