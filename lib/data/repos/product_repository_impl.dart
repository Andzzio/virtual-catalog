import 'package:virtual_catalog_app/domain/datasources/product_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/repos/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDatasource datasource;

  ProductRepositoryImpl({required this.datasource});

  @override
  Future<List<Product>> getProducts() async {
    return datasource.getProducts();
  }
}
