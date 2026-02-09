import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required double cardWidth})
    : _cardWidth = cardWidth;

  final double _cardWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 4, offset: Offset(2, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: SizedBox(
                width: double.infinity,
                child: Image.asset("assets/images/3a.jpeg", fit: BoxFit.cover),
              ),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: Column(
                    children: [
                      Text(
                        "Mini Black Skirt",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(
                            fontSize: 16,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "S/. 45.50",
                        style: GoogleFonts.getFont(FontNames.fontNameP),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
