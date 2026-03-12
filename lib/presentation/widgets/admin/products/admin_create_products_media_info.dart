import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class AdminCreateProductsMediaInfo extends StatelessWidget {
  const AdminCreateProductsMediaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Media",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        Text(
          "Sube las imágenes de tus productos.",
          style: GoogleFonts.getFont(FontNames.fontNameH2),
        ),
      ],
    );
  }
}
