import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/data/services/nubefact_service.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/domain/entities/sale_item.dart';
import 'package:virtual_catalog_app/domain/entities/stock_movement.dart';
import 'package:virtual_catalog_app/domain/repos/stock_movement_repository.dart';
import 'package:virtual_catalog_app/domain/usecases/create_sale.dart';
import 'package:virtual_catalog_app/domain/usecases/get_sales.dart';

class SalesProvider extends ChangeNotifier {
  final GetSales getSalesUseCase;
  final CreateSale createSaleUseCase;
  final StockMovementRepository stockMovementRepository;
  final NubefactService _nubefactService = NubefactService();

  SalesProvider({
    required this.getSalesUseCase,
    required this.createSaleUseCase,
    required this.stockMovementRepository,
  });

  List<Sale> sales = [];
  bool isLoading = false;

  Future<void> loadSales(String businessSlug) async {
    isLoading = true;
    notifyListeners();
    try {
      sales = await getSalesUseCase(businessSlug);
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<void> emitSale({
    required String businessSlug,
    required String customerName,
    required String customerDoc,
    required String customerAddress,
    required String customerPhone,
    required String documentType,
    required String paymentMethod,
    required List<SaleItem> items,
    required String notes,
    required String userId,
    required String userName,
    required List<Product> currentProducts,
    required Future<void> Function(Product) onUpdateProduct,
    Business? business,
  }) async {
    if (items.isEmpty) throw Exception("La venta requiere al menos un item");
    if (documentType == 'factura' && customerDoc.trim().length != 11) {
      throw Exception("Factura requiere RUC válido (11 dígitos)");
    }

    final total = items.fold<double>(0.0, (acc, item) => acc + item.lineTotal);
    final double igv;
    final double subtotal;
    final String prefix;

    if (documentType == 'nota_venta') {
      igv = 0.0;
      subtotal = total;
      prefix = 'NV01';
    } else {
      igv = double.parse((total - (total / 1.18)).toStringAsFixed(2));
      subtotal = double.parse((total - igv).toStringAsFixed(2));
      prefix = documentType == 'boleta' ? 'B001' : 'F001';
    }

    final count = sales.where((s) => s.documentType == documentType).length + 1;
    final number = '$prefix-${count.toString().padLeft(6, '0')}';

    String? sunatStatus;
    String? sunatDescription;
    String? sunatHash;
    String? pdfUrl;
    String? xmlUrl;
    String? cdrUrl;

    if (documentType != 'nota_venta' &&
        business != null &&
        business.nubefactUrl != null &&
        business.nubefactUrl!.isNotEmpty &&
        business.nubefactToken != null &&
        business.nubefactToken!.isNotEmpty) {
      final customerDocType = customerDoc.trim().length == 11 ? '6' : '1';

      final nubefactItems = items.map((item) {
        final itemIgv = double.parse((item.lineTotal - (item.lineTotal / 1.18)).toStringAsFixed(2));
        return _nubefactService.buildItemPayload(
          description: '${item.productName}${item.variantName.isNotEmpty ? " (${item.variantName})" : ""}',
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          igvAmount: itemIgv,
          lineTotal: item.lineTotal,
        );
      }).toList();

      final payload = _nubefactService.buildInvoicePayload(
        documentType: documentType,
        serie: prefix,
        correlativo: count,
        customerDocType: customerDocType,
        customerDoc: customerDoc.trim(),
        customerName: customerName.trim(),
        customerAddress: customerAddress.trim(),
        emissionDate: DateTime.now(),
        subtotal: subtotal,
        igv: igv,
        total: total,
        items: nubefactItems,
      );

      final nubefactResponse = await _nubefactService.emitInvoice(
        url: business.nubefactUrl!,
        token: business.nubefactToken!,
        payload: payload,
      );

      sunatStatus = nubefactResponse.accepted ? 'accepted' : 'rejected';
      sunatDescription = nubefactResponse.description;
      sunatHash = nubefactResponse.hash;
      pdfUrl = nubefactResponse.pdfUrl;
      xmlUrl = nubefactResponse.xmlUrl;
      cdrUrl = nubefactResponse.cdrUrl;

      if (!nubefactResponse.accepted) {
        throw Exception("SUNAT rechazó el comprobante: ${nubefactResponse.description}");
      }
    }

    final sale = Sale(
      id: '',
      number: number,
      documentType: documentType,
      customerName: customerName.trim(),
      customerDoc: customerDoc.trim(),
      customerAddress: customerAddress.trim(),
      customerPhone: customerPhone.trim(),
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      igv: igv,
      total: total,
      notes: notes.trim(),
      userId: userId,
      userName: userName,
      createdAt: DateTime.now(),
      items: items,
      sunatStatus: sunatStatus,
      sunatDescription: sunatDescription,
      sunatHash: sunatHash,
      pdfUrl: pdfUrl,
      xmlUrl: xmlUrl,
      cdrUrl: cdrUrl,
    );

    for (var item in items) {
      final productIndex = currentProducts.indexWhere((p) => p.id == item.productId);
      if (productIndex == -1) {
        throw Exception("Producto ${item.productName} no encontrado");
      }
      final product = currentProducts[productIndex];

      final variantIndex = product.variants.indexWhere((v) => v.name == item.variantName);
      if (variantIndex == -1) {
        throw Exception("Variante ${item.variantName} no encontrada");
      }
      final variant = product.variants[variantIndex];

      if (variant.stock < item.quantity) {
        throw Exception("Stock insuficiente de ${product.name} - ${variant.name} (disp: ${variant.stock})");
      }

      final newStock = variant.stock - item.quantity;
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
        salesCount: product.salesCount + item.quantity,
        isAvailable: product.isAvailable,
        sku: product.sku,
        variants: newVariants,
      );

      await onUpdateProduct(updatedProduct);

      final movement = StockMovement(
        id: '',
        productId: item.productId,
        productName: product.name,
        productSku: variant.sku ?? product.sku,
        variantName: item.variantName,
        type: 'egreso',
        quantity: item.quantity,
        stockAfter: newStock,
        reason: "Venta $number",
        reference: '',
        userId: userId,
        userName: userName,
        createdAt: DateTime.now(),
      );

      await stockMovementRepository.registerMovement(businessSlug, movement);
    }

    await createSaleUseCase(businessSlug, sale);
    await loadSales(businessSlug);
  }
}
