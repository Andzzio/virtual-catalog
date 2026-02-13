import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;
  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: 30),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "S/. ${product.price}",
            style: GoogleFonts.getFont(
              FontNames.fontNameP,
              textStyle: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 15),
          Divider(color: const Color.fromARGB(255, 226, 225, 225)),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            shape: Border(),
            title: Text(
              "DESCRIPCIÓN",
              style: GoogleFonts.getFont(
                FontNames.fontNameP,
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    product.description,
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: const Color.fromARGB(255, 226, 225, 225)),
          SizedBox(height: 30),
          Text("Talla"),
          SizedBox(height: 10),
          Text("Color"),
          SizedBox(height: 10),
          Text("Stock"),
        ],
      ),
    );
  }
}
