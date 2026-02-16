import 'package:virtual_catalog_app/domain/datasources/product_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/repos/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDatasource datasource;

  ProductRepositoryImpl({required this.datasource});

  @override
  Future<List<Product>> getProducts(String businessSlug) async {
    return datasource.getProducts(businessSlug);
  }

  @override
  Future<Product?> getProductById(String businessSlug, String productId) {
    return datasource.getProductById(businessSlug, productId);
  }
}
