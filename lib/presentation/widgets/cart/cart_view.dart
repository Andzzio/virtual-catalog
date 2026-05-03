import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_footer.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_item_list.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/empty_cart.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPaddings.p24, vertical: AppPaddings.p24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Tu Carrito",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppPaddings.p12),
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${cartProvider.itemCount}",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameP,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: cartProvider.isEmpty
              ? EmptyCart()
              : CartItemList(cartProvider: cartProvider),
        ),
        if (!cartProvider.isEmpty) CartFooter(cartProvider: cartProvider),
      ],
    );
  }
}
