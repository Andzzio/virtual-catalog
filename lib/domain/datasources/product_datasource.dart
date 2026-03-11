import 'package:virtual_catalog_app/domain/entities/product.dart';

abstract class ProductDatasource {
  Future<List<Product>> getProducts(String businessSlug);
  Future<Product?> getProductById(String businessSlug, String productId);

  Future<String> addProduct(String businessSlug, Product product);
  Future<void> updateProduct(String businessSlug, Product product);
  Future<void> deleteProduct(String businessSlug, String productId);
}
