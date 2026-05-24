class SaleItem {
  final String productId;
  final String productName;
  final String? productSku;
  final String variantName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  SaleItem({
    required this.productId,
    required this.productName,
    this.productSku,
    required this.variantName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });
}
