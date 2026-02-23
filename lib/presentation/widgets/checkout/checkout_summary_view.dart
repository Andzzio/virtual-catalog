import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/checkout/summary_footer.dart';
import 'package:virtual_catalog_app/presentation/widgets/checkout/summary_item_list.dart';

class CheckoutSummaryView extends StatelessWidget {
  const CheckoutSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Resumen del pedido",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(height: 20),
              Expanded(child: SummaryItemList(cartProvider: cartProvider)),
              SummaryFooter(cartProvider: cartProvider),
            ],
          ),
        ),
      ),
    );
  }
}
