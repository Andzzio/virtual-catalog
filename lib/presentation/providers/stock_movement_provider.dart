import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';
import 'package:virtual_catalog_app/domain/entities/stock_movement.dart';
import 'package:virtual_catalog_app/domain/repos/stock_movement_repository.dart';

class StockMovementProvider extends ChangeNotifier {
  final StockMovementRepository repository;

  StockMovementProvider({required this.repository});

  List<StockMovement> movements = [];
  bool isLoading = false;

  Future<void> loadMovements(String businessSlug) async {
    isLoading = true;
    notifyListeners();
    try {
      movements = await repository.getMovements(businessSlug);
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<void> registerMovement({
    required String businessSlug,
    required String productId,
    required String variantName,
    required String type,
    required int quantity,
    required String? reason,
    required String? reference,
    required String userId,
    required String userName,
    required List<Product> currentProducts,
    required Future<void> Function(Product) onUpdateProduct,
  }) async {
    final productIndex = currentProducts.indexWhere((p) => p.id == productId);
    if (productIndex == -1) throw Exception("Producto no encontrado");
    final product = currentProducts[productIndex];

    final variantIndex = product.variants.indexWhere((v) => v.name == variantName);
    if (variantIndex == -1) throw Exception("Variante no encontrada");
    final variant = product.variants[variantIndex];

    int newStock;
    if (type == 'ingreso') {
      newStock = variant.stock + quantity;
    } else {
      if (variant.stock < quantity) {
        throw Exception("Stock insuficiente para realizar el egreso");
      }
      newStock = variant.stock - quantity;
    }

    final newVariants = List<ProductVariant>.from(product.variants);
    newVariants[variantIndex] = ProductVariant(
      sku: variant.sku,
      name: variant.name,
      color: variant.color,
      price: variant.price,
      discountPrice: variant.discountPrice,
      stock: newStock,
      sizes: variant.sizes,
    );

    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      description: product.description,
      imageUrl: product.imageUrl,
      businessId: product.businessId,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
      category: product.category,
      salesCount: product.salesCount,
      isAvailable: product.isAvailable,
      sku: product.sku,
      variants: newVariants,
    );

    await onUpdateProduct(updatedProduct);

    final movement = StockMovement(
      id: '',
      productId: productId,
      productName: product.name,
      productSku: variant.sku ?? product.sku,
      variantName: variantName,
      type: type,
      quantity: quantity,
      stockAfter: newStock,
      reason: reason,
      reference: reference,
      userId: userId,
      userName: userName,
      createdAt: DateTime.now(),
    );

    await repository.registerMovement(businessSlug, movement);
    await loadMovements(businessSlug);
  }
}
