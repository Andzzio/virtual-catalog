class Product {
  final String id;
  final String businessId;
  final String? sku;
  final String name;
  final String description;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final int stock;
  final bool isAvailable;
  final List<String> imageUrl;
  final double? discountPrice;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.businessId,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.stock,
    this.isAvailable = true,
    this.discountPrice,
    this.sku,
  });
}
