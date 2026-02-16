import 'package:virtual_catalog_app/domain/datasources/cart_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';
import 'package:virtual_catalog_app/domain/repos/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartDatasource datasource;
  CartRepositoryImpl({required this.datasource});
  @override
  Future<List<CartItem>> loadCart(String slug) => datasource.loadCart(slug);
  @override
  Future<void> saveCart(String slug, List<CartItem> items) =>
      datasource.saveCart(slug, items);
  @override
  Future<void> clearCart(String slug) => datasource.clearCart(slug);
}
