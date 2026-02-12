class ProductVariant {
  final String name;
  final int? color;
  final int stock;
  final List<String> sizes;

  ProductVariant({
    required this.name,
    this.color,
    required this.stock,
    required this.sizes,
  });
}
