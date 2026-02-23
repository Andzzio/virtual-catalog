import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';
import 'package:virtual_catalog_app/domain/entities/payment_method.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';
import 'package:virtual_catalog_app/domain/repos/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository repository;
  CartMode mode = CartMode.buyCart;
  DeliveryMethod? _selectedDeliveryMethod;
  PaymentMethod? _selectedPaymentMethod;

  List<CartItem> _checkoutItems = [];
  //constructor
  CartProvider({required this.repository});

  //Todos los carritos
  final Map<String, List<CartItem>> _carts = {};
  //Negocio actual
  String? _currentSlug;

  DeliveryMethod? get selectedDeliveryMethod => _selectedDeliveryMethod;

  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;

  List<CartItem> get checkItems => List.unmodifiable(_checkoutItems);

  //Items del carrito del negocio actual
  List<CartItem> get _currentItems =>
      _currentSlug != null ? (_carts[_currentSlug] ?? []) : [];
  //getter para acceder al carrito actual desde fuera
  List<CartItem> get items => List.unmodifiable(_currentItems);
  //getter para acceder a la cantidad de items
  int get itemCount => _currentItems.fold(
    0,
    (previousValue, element) => previousValue + element.quantity,
  );
  //getter para saber si el carrito está vacío
  bool get isEmpty => _currentItems.isEmpty;
  //getter para el saber total original sin descuentos
  double get totalOriginal => _currentItems.fold(
    0,
    (previousValue, element) => previousValue + element.originalSubTotal,
  );
  // getter para saber el total con descuentos
  double get totalWithDiscounts => _currentItems.fold(
    0,
    (previousValue, element) => previousValue + element.subTotal,
  );
  //getter para saber el ahorro del total
  double get totalSavings => totalOriginal - totalWithDiscounts;
  //getter para saber si hay ahorros
  bool get hasSavings => totalSavings > 0;

  //getter para acceder a la cantidad de items
  int get checkItemCount => _checkoutItems.fold(
    0,
    (previousValue, element) => previousValue + element.quantity,
  );
  //getter para saber si el carrito está vacío
  bool get checkItemsisEmpty => _checkoutItems.isEmpty;
  //getter para el saber total original sin descuentos
  double get checkItemsTotalOriginal => _checkoutItems.fold(
    0,
    (previousValue, element) => previousValue + element.originalSubTotal,
  );
  // getter para saber el total con descuentos
  double get checkItemsTotalWithDiscounts => _checkoutItems.fold(
    0,
    (previousValue, element) => previousValue + element.subTotal,
  );
  //getter para saber el ahorro del total
  double get checkItemsTotalSavings =>
      checkItemsTotalOriginal - checkItemsTotalWithDiscounts;
  //getter para saber si hay ahorros
  bool get checkItemsHasSavings => checkItemsTotalSavings > 0;

  double get checkoutGrandTotal =>
      checkItemsTotalWithDiscounts + (_selectedDeliveryMethod?.price ?? 0);

  void setDeliveryMethod(DeliveryMethod method) {
    _selectedDeliveryMethod = method;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setBuyNow(
    CartItem item,
    List<DeliveryMethod> deliveryMethods,
    List<PaymentMethod> paymentMethods,
  ) {
    _checkoutItems = [item];
    _selectedDeliveryMethod = deliveryMethods.isNotEmpty
        ? deliveryMethods.first
        : null;
    _selectedPaymentMethod = paymentMethods.isNotEmpty
        ? paymentMethods.first
        : null;
    setMode(CartMode.buyNow);
    notifyListeners();
  }

  void setBuyCart(
    List<CartItem> items,
    List<DeliveryMethod> deliveryMethods,
    List<PaymentMethod> paymentMethods,
  ) {
    _checkoutItems = List.from(items);
    _selectedDeliveryMethod = deliveryMethods.isNotEmpty
        ? deliveryMethods.first
        : null;
    _selectedPaymentMethod = paymentMethods.isNotEmpty
        ? paymentMethods.first
        : null;
    setMode(CartMode.buyCart);
    notifyListeners();
  }

  void clearBuy() {
    _checkoutItems.clear();
    notifyListeners();
  }

  void setMode(CartMode mode) {
    this.mode = mode;
  }

  //método para establecer el slug actual del negocio y cargar el carrito del shared preference
  void setBusinessSlug(String slug) async {
    if (_currentSlug == slug) return;
    _currentSlug = slug;
    _checkoutItems.clear();
    if (!_carts.containsKey(slug)) {
      _carts[slug] = await repository.loadCart(slug);
    }
    notifyListeners();
  }

  //método para guardar el carrito en el shared preference
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

enum CartMode { buyNow, buyCart }
