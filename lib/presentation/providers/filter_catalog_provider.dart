import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';

class FilterCatalogProvider extends ChangeNotifier {
  ProductProvider _productProvider;
  List<Product> _products = [];
  String _searchQuery = "";
  String _selectedOrder = "Relevantes";
  String _selectedCategory = "Todos";
  double _minPrice = 0;
  double _maxPrice = 0;
  final Set<String> _selectedSizes = {};
  bool _isAvailable = false;

  FilterCatalogProvider(this._productProvider) {
    _products = _productProvider.products;
    _productProvider.addListener(_onProductChanged);
  }

  String get selectedOrder => _selectedOrder;

  String get selectedCategory => _selectedCategory;

  String get searchQuery => _searchQuery;

  double get minPrice => _minPrice;

  double get maxPrice => _maxPrice;

  Set<String> get selectedSizes => _selectedSizes;

  bool get isAvailable => _isAvailable;

  List<Product> get filteredProducts {
    final filtered = _products.where((product) {
      final productPrice = product.variants
          .map((variant) {
            return variant.discountPrice ?? variant.price;
          })
          .reduce((a, b) => a < b ? a : b);

      final matchMinPrice = _minPrice == 0 || productPrice >= _minPrice;
      final matchMaxPrice = _maxPrice == 0 || productPrice <= _maxPrice;

      final matchSearch = product.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchCategory =
          _selectedCategory == "Todos" || product.category == _selectedCategory;

      final matchSize =
          _selectedSizes.isEmpty ||
          product.variants.any((variant) {
            return variant.sizes.any((size) {
              return _selectedSizes.contains(size);
            });
          });
      final matchAvailable = !_isAvailable || product.isAvailable;
      return matchSearch &&
          matchCategory &&
          matchMinPrice &&
          matchMaxPrice &&
          matchSize &&
          matchAvailable;
    }).toList();

    if (_selectedOrder == "Mayor Precio") {
      filtered.sort((a, b) {
        final aPrice = a.variants
            .map((variant) => variant.discountPrice ?? variant.price)
            .reduce((x, y) => x < y ? x : y);
        final bPrice = b.variants
            .map((variant) => variant.discountPrice ?? variant.price)
            .reduce((x, y) => x < y ? x : y);
        return bPrice.compareTo(aPrice);
      });
    } else if (_selectedOrder == "Menor Precio") {
      filtered.sort((a, b) {
        final aPrice = a.variants
            .map((variant) => variant.discountPrice ?? variant.price)
            .reduce((x, y) => x < y ? x : y);
        final bPrice = b.variants
            .map((variant) => variant.discountPrice ?? variant.price)
            .reduce((x, y) => x < y ? x : y);
        return aPrice.compareTo(bPrice);
      });
    }

    return filtered;
  }

  List<String> get sizes {
    final allSizes = _products
        .expand((product) => product.variants)
        .expand((variant) => variant.sizes)
        .toSet()
        .toList();
    allSizes.sort();
    return allSizes;
  }

  List<String> get categories {
    final allCats = _products
        .map((product) => product.category)
        .toSet()
        .toList();
    allCats.sort();
    allCats.insert(0, "Todos");
    return allCats;
  }

  void toggleAvailable() {
    _isAvailable = !_isAvailable;
    notifyListeners();
  }

  void toggleSize(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
    notifyListeners();
  }

  void setMinPrice(double price) {
    _minPrice = price;
    notifyListeners();
  }

  void setMaxPrice(double price) {
    _maxPrice = price;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectOrder(String order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = "";
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = "";
    _selectedCategory = "Todos";
    _selectedOrder = "Relevantes";
    _minPrice = 0;
    _maxPrice = 0;
    _selectedSizes.clear();
    _isAvailable = false;
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
