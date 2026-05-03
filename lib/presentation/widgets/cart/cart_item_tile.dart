import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_image.dart';
import 'package:virtual_catalog_app/presentation/widgets/quantity_selector.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final int index;
  const CartItemTile({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = context.read<CartProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPaddings.p24, vertical: AppPaddings.p16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppBorders.radiusImage),
            child: CatalogImage(
              optimizedWidth: 100,
              imageUrl: item.product.imageUrl[0],
              width: 80,
              height: 100,
            ),
          ),
          const SizedBox(width: AppPaddings.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: GoogleFonts.getFont(FontNames.fontNameP, textStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "S/. ${item.subTotal.toStringAsFixed(2)}",
                      style: GoogleFonts.getFont(FontNames.fontNameP, textStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.variant.name} • ${item.size}",
                  style: GoogleFonts.getFont(FontNames.fontNameP, textStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "S/. ${item.unitPrice.toStringAsFixed(2)} c/u",
                      style: GoogleFonts.getFont(FontNames.fontNameP, textStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ),
                    if (item.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        "S/. ${item.originalUnitPrice.toStringAsFixed(2)}",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameP,
                          textStyle: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
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
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => cartProvider.removeItem(index),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      splashRadius: 20,
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
