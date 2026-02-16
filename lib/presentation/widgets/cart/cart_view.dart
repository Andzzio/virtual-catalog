import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Text(
                "Carrito de Compras",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${cartProvider.itemCount}",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameP,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.close),
              ),
            ],
          ),
        ),
        Divider(height: 1),
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
