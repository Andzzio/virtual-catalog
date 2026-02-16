import 'package:virtual_catalog_app/domain/entities/product_variant.dart';

class ProductVariantModel {
  final String name;
  final int? color;
  final int stock;
  final List<String> sizes;
  final double price;
  final double? discountPrice;
  ProductVariantModel({
    required this.name,
    this.color,
    required this.stock,
    required this.sizes,
    required this.price,
    this.discountPrice,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      name: json['name'],
      color: json['color'],
      stock: json['stock'],
      sizes: List<String>.from(json['sizes']),
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'color': color,
    'stock': stock,
    'sizes': sizes,
    'price': price,
    'discountPrice': discountPrice,
  };

  ProductVariant toEntity() => ProductVariant(
    name: name,
    color: color,
    stock: stock,
    sizes: sizes,
    price: price,
    discountPrice: discountPrice,
  );

  factory ProductVariantModel.fromEntity(ProductVariant entity) {
    return ProductVariantModel(
      name: entity.name,
      color: entity.color,
      stock: entity.stock,
      sizes: entity.sizes,
      price: entity.price,
      discountPrice: entity.discountPrice,
    );
  }
}
