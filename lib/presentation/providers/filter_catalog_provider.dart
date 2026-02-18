import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';

class FilterCatalogProvider extends ChangeNotifier {
  ProductProvider _productProvider;
  List<Product> _products = [];
  String _selectedOrder = "Relevantes";
  String _selectedCategory = "Todos";

  FilterCatalogProvider(this._productProvider) {
    _products = _productProvider.products;
    _productProvider.addListener(_onProductChanged);
  }

  String get selectedOrder => _selectedOrder;

  String get selectedCategory => _selectedCategory;

  List<Product> get filteredProducts => _products.where((product) {
    return true;
  }).toList();

  List<String> get categories {
    final allCats = _products
        .map((product) => product.category)
        .toSet()
        .toList();
    allCats.sort();
    allCats.insert(0, "Todos");
    return allCats;
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectOrder(String order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void _onProductChanged() {
    _products = _productProvider.products;
    notifyListeners();
  }

  void updateProvider(ProductProvider newProvider) {
    if (_productProvider == newProvider) return;
    _productProvider.removeListener(_onProductChanged);
    _productProvider = newProvider;
    _productProvider.addListener(_onProductChanged);
  }

  @override
  void dispose() {
    _productProvider.removeListener(_onProductChanged);
    super.dispose();
  }
}
