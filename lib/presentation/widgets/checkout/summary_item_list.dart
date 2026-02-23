import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/checkout/summary_item_tile.dart';

class SummaryItemList extends StatelessWidget {
  const SummaryItemList({super.key, required this.cartProvider});

  final CartProvider cartProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cartProvider.checkItems.length,
      itemBuilder: (context, index) {
        final item = cartProvider.checkItems[index];
        return SummaryItemTile(item: item);
      },
    );
  }
}
