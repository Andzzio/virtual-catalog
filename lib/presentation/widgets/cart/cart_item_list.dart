import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_item_tile.dart';

class CartItemList extends StatelessWidget {
  final CartProvider cartProvider;
  const CartItemList({super.key, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cartProvider.items.length,
      itemBuilder: (BuildContext context, int index) {
        return CartItemTile(item: cartProvider.items[index], index: index);
      },
    );
  }
}
