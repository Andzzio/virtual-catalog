import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';

class CartItem {
  Product product;
  ProductVariant variant;
  String size;
  int quantity;

  CartItem({
    required this.product,
    required this.variant,
    required this.size,
    required this.quantity,
  });

  double get unitPrice => variant.discountPrice ?? variant.price;
  double get originalUnitPrice => variant.price;
  double get subTotal => unitPrice * quantity;
  double get originalSubTotal => originalUnitPrice * quantity;
  bool get hasDiscount => variant.discountPrice != null;
  double get savings => originalSubTotal - subTotal;
}
