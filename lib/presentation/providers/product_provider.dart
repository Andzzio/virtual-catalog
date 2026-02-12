import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/repos/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider({required this.repository});

  List<Product> products = [];
  bool isLoading = false;

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();
    products = await repository.getProducts();
    isLoading = false;
    notifyListeners();
  }
}
