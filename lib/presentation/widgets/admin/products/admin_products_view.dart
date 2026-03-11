import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

import 'admin_product_table.dart';

class AdminProductsView extends StatelessWidget {
  const AdminProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Productos",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "Administra tu inventario.",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                ),
                label: Text(
                  "Crear Producto",
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE2E2E2)),
            ),
            child: Row(
              children: [
                Expanded(child: TextField(decoration: _inputDecoration())),
                SizedBox(width: 15),
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    side: BorderSide(color: Color(0xFFE2E2E2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.filter_alt),
                  label: Text(
                    "Filtrar",
                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                  ),
                ),
                SizedBox(width: 15),
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    side: BorderSide(color: Color(0xFFE2E2E2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.sort),
                  label: Text(
                    "Ordenar",
                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: AdminProductTable()),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      prefixIcon: Icon(Icons.search),
      hintText: "Buscar productos por nombre...",
      hintStyle: GoogleFonts.getFont(
        FontNames.fontNameH2,
        textStyle: TextStyle(color: Colors.grey),
      ),
      prefixIconColor: Colors.grey,
      filled: true,
      fillColor: Color.fromARGB(255, 238, 239, 240),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE2E2E2)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
