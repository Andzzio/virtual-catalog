import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
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
        salesCount: product.salesCount,
      ),
    );
    _sortProductsByCategory();
    notifyListeners();
  }

  List<Product> getProductsForBlock(HomeBlock block) {
    List<Product> activeProducts = products.where((p) => p.isAvailable).toList();

    switch (block.sortCriteria) {
      case BlockSortCriteria.newest:
        activeProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case BlockSortCriteria.recentlyUpdated:
        activeProducts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case BlockSortCriteria.alphabetical:
        activeProducts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case BlockSortCriteria.bestSelling:
        activeProducts.sort((a, b) => b.salesCount.compareTo(a.salesCount));
        break;
      case BlockSortCriteria.biggestDiscount:
        activeProducts.sort((a, b) {
          double maxDiffA = _getMaxDiscount(a);
          double maxDiffB = _getMaxDiscount(b);
          return maxDiffB.compareTo(maxDiffA);
        });
        break;
      case BlockSortCriteria.premiumFirst:
        activeProducts.sort((a, b) {
          double maxA = _getMaxPrice(a);
          double maxB = _getMaxPrice(b);
          return maxB.compareTo(maxA);
        });
        break;
      case BlockSortCriteria.affordableFirst:
        activeProducts.sort((a, b) {
          double minA = _getMinPrice(a);
          double minB = _getMinPrice(b);
          return minA.compareTo(minB);
        });
        break;
      case BlockSortCriteria.manual:
        if (block.specificProductId != null) {
          try {
            final specificProduct = activeProducts.firstWhere(
              (p) => p.id == block.specificProductId,
            );
            return [specificProduct];
          } catch (_) {
            // Si el producto fue eliminado o no existe, fall-back a vacio o no hacer nada
          }
        }
        break;
    }

    if (block.layout == BlockLayout.featured) {
      if (activeProducts.isNotEmpty) return [activeProducts.first];
      return [];
    }

    if (activeProducts.length > block.itemsLimit) {
      return activeProducts.sublist(0, block.itemsLimit);
    }
    return activeProducts;
  }

  double _getMaxDiscount(Product p) {
    double maxDiff = 0.0;
    for (var v in p.variants) {
      if (v.discountPrice != null && v.discountPrice! < v.price) {
        double diff = (v.price - v.discountPrice!) / v.price;
        if (diff > maxDiff) maxDiff = diff;
      }
    }
    return maxDiff;
  }

  double _getMaxPrice(Product p) {
    if (p.variants.isEmpty) return 0.0;
    return p.variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  double _getMinPrice(Product p) {
    if (p.variants.isEmpty) return 0.0;
    return p.variants.map((v) => v.discountPrice ?? v.price).reduce((a, b) => a < b ? a : b);
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
