import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';

class SummaryFooter extends StatelessWidget {
  const SummaryFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          SizedBox(height: 12),
          if (cartProvider.checkItemsHasSavings) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal",
                  style: GoogleFonts.getFont(FontNames.fontNameP),
                ),
                Text(
                  "S/. ${cartProvider.checkItemsTotalOriginal.toStringAsFixed(2)}",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameP,
                    textStyle: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ahorro", style: TextStyle(color: Colors.greenAccent)),
                Text(
                  "- S/. ${cartProvider.checkItemsTotalSavings.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ],
            ),
            SizedBox(height: 4),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Envío", style: GoogleFonts.getFont(FontNames.fontNameP)),
              Text(
                cartProvider.selectedDeliveryMethod?.price == 0
                    ? "Gratis"
                    : "S/. ${cartProvider.selectedDeliveryMethod?.price ?? 0}",
                style: GoogleFonts.getFont(FontNames.fontNameP),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              Text(
                "S/. ${cartProvider.checkoutGrandTotal.toStringAsFixed(2)}",
                style: GoogleFonts.getFont(FontNames.fontNameP),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
