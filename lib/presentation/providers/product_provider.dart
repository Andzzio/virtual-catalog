import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/repos/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider({required this.repository});

  List<Product> products = [];
  bool isLoading = false;
  String? _currentSlug;

  Future<void> loadProducts(String businessSlug) async {
    if (_currentSlug == businessSlug && products.isNotEmpty) return;
    isLoading = true;
    notifyListeners();
    _currentSlug = businessSlug;
    products = await repository.getProducts(businessSlug);
    isLoading = false;
    notifyListeners();
  }
}
