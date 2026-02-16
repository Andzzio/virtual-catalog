import 'package:virtual_catalog_app/data/models/product_variant_model.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';

class ProductModel {
  final String id;
  final String businessId;
  final String? sku;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final bool isAvailable;
  final List<String> imageUrl;
  final List<ProductVariantModel> variants;

  ProductModel({
    required this.id,
    required this.businessId,
    this.sku,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.isAvailable = true,
    required this.imageUrl,
    required this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      businessId: json['businessId'],
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      category: json['category'],
      isAvailable: json['isAvailable'] ?? true,
      imageUrl: List<String>.from(json['imageUrl']),
      variants: (json['variants'] as List)
          .map((v) => ProductVariantModel.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'businessId': businessId,
    'sku': sku,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'category': category,
    'isAvailable': isAvailable,
    'imageUrl': imageUrl,
    'variants': variants.map((v) => v.toJson()).toList(),
  };

  Product toEntity() => Product(
    id: id,
    businessId: businessId,
    sku: sku,
    name: name,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
    category: category,
    isAvailable: isAvailable,
    imageUrl: imageUrl,
    variants: variants.map((v) => v.toEntity()).toList(),
  );

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      businessId: entity.businessId,
      sku: entity.sku,
      name: entity.name,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      category: entity.category,
      isAvailable: entity.isAvailable,
      imageUrl: entity.imageUrl,
      variants: entity.variants
          .map((v) => ProductVariantModel.fromEntity(v))
          .toList(),
    );
  }
}
