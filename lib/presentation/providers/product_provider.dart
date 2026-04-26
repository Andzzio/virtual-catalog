import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/repos/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider({required this.repository});

  List<Product> products = [];
  bool isLoading = false;
  String? _currentSlug;

  void _sortProductsByCategory() {
    products.sort((a, b) => a.category.compareTo(b.category));
  }

  Future<void> loadProducts(String businessSlug) async {
    if (_currentSlug == businessSlug && products.isNotEmpty) return;
    isLoading = true;
    notifyListeners();
    _currentSlug = businessSlug;
    products = await repository.getProducts(businessSlug);
    _sortProductsByCategory();
    isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(String businessSlug, Product product) async {
    final newId = await repository.addProduct(businessSlug, product);
    products.add(
      Product(
        id: newId,
        name: product.name,
        description: product.description,
        imageUrl: product.imageUrl,
        businessId: product.businessId,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        category: product.category,
        variants: product.variants,
        sku: product.sku,
        isAvailable: product.isAvailable,
      ),
    );
    _sortProductsByCategory();
    notifyListeners();
  }

  Future<void> deleteProduct(String businessSlug, String productId) async {
    final backup = List<Product>.from(products);
    products.removeWhere((p) => p.id == productId);
    notifyListeners();
    try {
      await repository.deleteProduct(businessSlug, productId);
    } catch (e) {
      products = backup;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(String businessSlug, Product product) async {
    final backup = List<Product>.from(products);
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) products[index] = product;
    _sortProductsByCategory();
    notifyListeners();
    try {
      await repository.updateProduct(businessSlug, product);
    } catch (e) {
      products = backup;
      notifyListeners();
      rethrow;
    }
  }
}
