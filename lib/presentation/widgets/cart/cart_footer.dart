import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virtual_catalog_app/config/routers/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';

class CartFooter extends StatelessWidget {
  final CartProvider cartProvider;
  const CartFooter({super.key, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPaddings.p24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: AppColors.border),
          const SizedBox(height: AppPaddings.p12),
          if (cartProvider.hasSavings) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal",
                  style: GoogleFonts.getFont(FontNames.fontNameP, textStyle: const TextStyle(color: AppColors.textMuted)),
                ),
                Text(
                  "S/. ${cartProvider.totalOriginal.toStringAsFixed(2)}",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameP,
                    textStyle: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ahorro", style: GoogleFonts.getFont(FontNames.fontNameP, textStyle: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                Text(
                  "- S/. ${cartProvider.totalSavings.toStringAsFixed(2)}",
                  style: GoogleFonts.getFont(FontNames.fontNameP, textStyle: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: GoogleFonts.getFont(
                  FontNames.fontNameP,
                  textStyle: const TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
              ),
              Text(
                "S/. ${cartProvider.totalWithDiscounts.toStringAsFixed(2)}",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: -0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppPaddings.p24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final cartProvider = context.read<CartProvider>();
                final deliveryMethods =
                    context
                        .read<BusinessProvider>()
                        .business
                        ?.deliveryMethods ??
                    [];
                final paymentMethods =
                    context.read<BusinessProvider>().business?.paymentMethods ??
                    [];
                cartProvider.setBuyCart(
                  cartProvider.items,
                  deliveryMethods,
                  paymentMethods,
                );
                final slug = GoRouterState.of(
                  context,
                ).pathParameters["businessSlug"];
                NavigationHelper.go(context, "/$slug/checkout");
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorders.radiusButton),
                  ),
                ),
                minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
                elevation: const WidgetStatePropertyAll(0),
              ),
              child: Text(
                "Finalizar Pedido",
                style: GoogleFonts.getFont(FontNames.fontNameP, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
