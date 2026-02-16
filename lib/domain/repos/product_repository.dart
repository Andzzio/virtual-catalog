import 'package:virtual_catalog_app/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts(String businessSlug);
  Future<Product?> getProductById(String businessSlug, String productId);
}
