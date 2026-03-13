import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class AdminCreateProductsVariantsInfo extends StatelessWidget {
  final Function() onAdd;
  const AdminCreateProductsVariantsInfo({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Variantes",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        Text(
          "Maneja las variaciones como el color, talla, diseño y precio",
          style: GoogleFonts.getFont(FontNames.fontNameH2),
        ),
        SizedBox(height: 20),
        TextButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add),
          label: Text("Agregar variante"),
        ),
      ],
    );
  }
}
