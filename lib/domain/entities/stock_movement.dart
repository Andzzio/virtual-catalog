class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final String? productSku;
  final String variantName;
  final String type;
  final int quantity;
  final int stockAfter;
  final String? reason;
  final String? reference;
  final String userId;
  final String userName;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    this.productSku,
    required this.variantName,
    required this.type,
    required this.quantity,
    required this.stockAfter,
    this.reason,
    this.reference,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });
}
