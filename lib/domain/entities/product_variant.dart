class ProductVariant {
  final String name;
  final int? color;
  final int stock;
  final List<String> sizes;
  final double price;
  final double? discountPrice;

  ProductVariant({
    required this.name,
    this.color,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.sizes,
  });
}
