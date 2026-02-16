import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/quantity_selector.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final int index;
  const CartItemTile({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = context.read<CartProvider>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              item.product.imageUrl[0],
              width: 80,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.product.name,
                      style: GoogleFonts.getFont(FontNames.fontNameH2),
                    ),
                    Text(
                      "S/. ${item.subTotal.toStringAsFixed(2)}",
                      style: GoogleFonts.getFont(FontNames.fontNameP),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  item.size,
                  style: GoogleFonts.getFont(FontNames.fontNameP),
                ),
                Text(
                  item.variant.name,
                  style: GoogleFonts.getFont(FontNames.fontNameP),
                ),
                Text(
                  item.product.category,
                  style: GoogleFonts.getFont(FontNames.fontNameP),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "S/. ${item.unitPrice.toStringAsFixed(2)}",
                      style: GoogleFonts.getFont(FontNames.fontNameP),
                    ),
                    if (item.hasDiscount) ...[
                      SizedBox(width: 8),
                      Text(
                        "S/. ${item.originalUnitPrice.toStringAsFixed(2)}",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameP,
                          textStyle: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    QuantitySelector(
                      quantity: item.quantity,
                      onDecrement: () =>
                          cartProvider.updateQuantity(index, item.quantity - 1),
                      onIncrement: item.quantity < item.variant.stock
                          ? () => cartProvider.updateQuantity(
                              index,
                              item.quantity + 1,
                            )
                          : null,
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () => cartProvider.removeItem(index),
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
