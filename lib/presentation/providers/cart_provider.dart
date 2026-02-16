import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';
import 'package:virtual_catalog_app/domain/repos/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository repository;

  CartProvider({required this.repository});

  final Map<String, List<CartItem>> _carts = {};
  String? _currentSlug;

  List<CartItem> get _currentItems =>
      _currentSlug != null ? (_carts[_currentSlug] ?? []) : [];

  List<CartItem> get items => List.unmodifiable(_currentItems);
  int get itemCount => _currentItems.fold(
    0,
    (previousValue, element) => previousValue + element.quantity,
  );
  bool get isEmpty => _currentItems.isEmpty;
  double get totalOriginal => _currentItems.fold(
    0,
    (previousValue, element) => previousValue + element.originalSubTotal,
  );
  double get totalWithDiscounts => _currentItems.fold(
    0,
    (previousValue, element) => previousValue + element.subTotal,
  );
  double get totalSavings => totalOriginal - totalWithDiscounts;
  bool get hasSavings => totalSavings > 0;

  void setBusinessSlug(String slug) async {
    if (_currentSlug == slug) return;
    _currentSlug = slug;
    if (!_carts.containsKey(slug)) {
      _carts[slug] = await repository.loadCart(slug);
    }
    notifyListeners();
  }

  void _saveToStorage() {
    if (_currentSlug == null) return;
    repository.saveCart(_currentSlug!, _currentItems);
  }

  void addItem(
    Product product,
    ProductVariant variant,
    String size,
    int quantity,
  ) {
    _carts.putIfAbsent(_currentSlug!, () => []);
    final existingIndex = _currentItems.indexWhere(
      (element) =>
          element.product.id == product.id &&
          element.variant.name == variant.name &&
          element.size == size,
    );
    if (existingIndex != -1) {
      _currentItems[existingIndex].quantity += quantity;

      if (_currentItems[existingIndex].quantity > variant.stock) {
        _currentItems[existingIndex].quantity = variant.stock;
      }
    } else {
      _currentItems.add(
        CartItem(
          product: product,
          variant: variant,
          size: size,
          quantity: quantity,
        ),
      );
    }
    _saveToStorage();
    notifyListeners();
  }

  void removeItem(int index) {
    _currentItems.removeAt(index);
    _saveToStorage();
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
      return;
    }
    if (newQuantity > _currentItems[index].variant.stock) return;
    _currentItems[index].quantity = newQuantity;
    _saveToStorage();
    notifyListeners();
  }

  void clearCart() {
    _currentItems.clear();
    _saveToStorage();
    notifyListeners();
  }
}
