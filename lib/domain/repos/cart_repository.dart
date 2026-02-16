import 'package:virtual_catalog_app/domain/entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> loadCart(String slug);
  Future<void> saveCart(String slug, List<CartItem> items);
  Future<void> clearCart(String slug);
}
