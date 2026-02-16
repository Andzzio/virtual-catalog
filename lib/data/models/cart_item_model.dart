import 'package:virtual_catalog_app/data/models/product_model.dart';
import 'package:virtual_catalog_app/data/models/product_variant_model.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';

class CartItemModel {
  final ProductModel product;
  final ProductVariantModel variant;
  final String size;
  final int quantity;

  CartItemModel({
    required this.product,
    required this.variant,
    required this.size,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      variant: ProductVariantModel.fromJson(json['variant']),
      size: json['size'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'variant': variant.toJson(),
    'size': size,
    'quantity': quantity,
  };

  CartItem toEntity() => CartItem(
    product: product.toEntity(),
    variant: variant.toEntity(),
    size: size,
    quantity: quantity,
  );

  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      product: ProductModel.fromEntity(entity.product),
      variant: ProductVariantModel.fromEntity(entity.variant),
      size: entity.size,
      quantity: entity.quantity,
    );
  }
}
