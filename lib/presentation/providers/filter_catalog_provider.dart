import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';

class FilterCatalogProvider extends ChangeNotifier {
  ProductProvider _productProvider;
  List<Product> _products = [];

  FilterCatalogProvider(this._productProvider) {
    _products = _productProvider.products;
    _productProvider.addListener(_onProductChanged);
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
