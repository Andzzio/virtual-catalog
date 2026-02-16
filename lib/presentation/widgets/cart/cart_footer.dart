import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';

class CartFooter extends StatelessWidget {
  final CartProvider cartProvider;
  const CartFooter({super.key, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          SizedBox(height: 12),
          if (cartProvider.hasSavings) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal",
                  style: GoogleFonts.getFont(FontNames.fontNameP),
                ),
                Text(
                  "S/. ${cartProvider.totalOriginal.toStringAsFixed(2)}",
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
                  "- S/. ${cartProvider.totalSavings.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ],
            ),
            SizedBox(height: 4),
          ],
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
                "S/. ${cartProvider.totalWithDiscounts.toStringAsFixed(2)}",
                style: GoogleFonts.getFont(FontNames.fontNameP),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.black),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 70)),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.grey.shade700;
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.grey.shade800;
                  }
                  return null;
                }),
              ),
              child: Text("Pagar"),
            ),
          ),
        ],
      ),
    );
  }
}
