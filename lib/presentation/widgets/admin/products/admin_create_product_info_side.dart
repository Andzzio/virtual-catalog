import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class AdminCreateProductInfoSide extends StatelessWidget {
  const AdminCreateProductInfoSide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Información Básica",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        Text(
          "Esta información será mostrada en los detalles de cada producto.",
          style: GoogleFonts.getFont(FontNames.fontNameH2),
        ),
      ],
    );
  }
}
