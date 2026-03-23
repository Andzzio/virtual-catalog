import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class AdminCreateProductFormSide extends StatelessWidget {
  final Function(String) onNameChanged;
  final Function(String) onCategoryChanged;
  final Function(String) onSkuChanged;
  final Function(String) onDescriptionChanged;
  final String? initialName;
  final String? initialCategory;
  final String? initialSku;
  final String? initialDescription;

  const AdminCreateProductFormSide({
    super.key,
    required this.onNameChanged,
    required this.onCategoryChanged,
    required this.onSkuChanged,
    required this.onDescriptionChanged,
    this.initialName,
    this.initialCategory,
    this.initialSku,
    this.initialDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nombre del Producto",
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: initialName,
            decoration: _inputDecoration(hintText: "ej. Camiseta Amarilla..."),
            onChanged: (value) => onNameChanged(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "El nombre es obligatorio";
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Categoría",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: initialCategory,
                      decoration: _inputDecoration(
                        hintText: "ej. Pantalones...",
                      ),
                      onChanged: (value) => onCategoryChanged(value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "La categoría es obligatoria";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SKU (Opcional)",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: initialSku,
                      decoration: _inputDecoration(hintText: "VC-001..."),
                      onChanged: (value) => onSkuChanged(value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Descripción",
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: initialDescription,
            decoration: _inputDecoration(
              hintText:
                  "Describe las características y materiales del producto...",
            ),
            maxLines: 5,
            onChanged: (value) => onDescriptionChanged(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "La descripción es obligatoria";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String hintText = ""}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.getFont(
        FontNames.fontNameH2,
        textStyle: TextStyle(color: Colors.grey),
      ),
      filled: true,
      fillColor: Color.fromARGB(255, 255, 255, 255),
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
