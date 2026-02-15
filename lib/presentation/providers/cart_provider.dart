import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(
    0,
    (previousValue, element) => previousValue + element.quantity,
  );
  bool get isEmpty => _items.isEmpty;
  double get totalOriginal => _items.fold(
    0,
    (previousValue, element) => previousValue + element.originalSubTotal,
  );
  double get totalWithDiscounts => _items.fold(
    0,
    (previousValue, element) => previousValue + element.subTotal,
  );
  double get totalSavings => totalOriginal - totalWithDiscounts;
  bool get hasSavings => totalSavings > 0;

  void addItem(
    Product product,
    ProductVariant variant,
    String size,
    int quantity,
  ) {
    final existingIndex = _items.indexWhere(
      (element) =>
          element.product.id == product.id &&
          element.variant.name == variant.name &&
          element.size == size,
    );
    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;

      if (_items[existingIndex].quantity > variant.stock) {
        _items[existingIndex].quantity = variant.stock;
      }
    } else {
      _items.add(
        CartItem(
          product: product,
          variant: variant,
          size: size,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
      return;
    }
    if (newQuantity > _items[index].variant.stock) return;
    _items[index].quantity = newQuantity;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
