import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';

class ProductInfoSection extends StatefulWidget {
  final Product product;
  const ProductInfoSection({super.key, required this.product});

  @override
  State<ProductInfoSection> createState() => _ProductInfoSectionState();
}

class _ProductInfoSectionState extends State<ProductInfoSection> {
  int selectedVariantIndex = 0;
  String? selectedSize;
  @override
  Widget build(BuildContext context) {
    final selectedVariant = widget.product.variants.isNotEmpty
        ? widget.product.variants[selectedVariantIndex]
        : null;
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: 30),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "S/. ${selectedVariant?.specificPrice ?? widget.product.price}",
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
                    widget.product.description,
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
          Text(
            "Talla",
            style: GoogleFonts.getFont(
              FontNames.fontNameP,
              textStyle: TextStyle(fontSize: 17),
            ),
          ),
          SizedBox(height: 10),
          if (selectedVariant != null)
            SelectionContainer.disabled(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: selectedVariant.sizes.map((size) {
                  final isSizeSelected = selectedSize == size;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSize = size;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSizeSelected ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: isSizeSelected
                              ? null
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          size,
                          style: GoogleFonts.getFont(
                            FontNames.fontNameP,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSizeSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          SizedBox(height: 10),
          if (selectedVariant != null)
            Text(
              "Color ${selectedVariant.name}",
              style: GoogleFonts.getFont(
                FontNames.fontNameP,
                textStyle: TextStyle(fontSize: 17),
              ),
            ),
          SizedBox(height: 10),
          Wrap(
            children: List.generate(widget.product.variants.length, (index) {
              final variant = widget.product.variants[index];
              final isSelected = selectedVariantIndex == index;

              final Color color = variant.color != null
                  ? Color(variant.color!)
                  : Colors.grey;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVariantIndex = index;
                      final newVariant = widget.product.variants[index];
                      if (newVariant.sizes.contains(selectedSize)) {
                      } else {
                        selectedSize = null;
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.all(2),
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: !isSelected
                            ? Border.all(color: Colors.black12)
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 10),
          Text(
            "Stock: ${selectedVariant != null ? selectedVariant.stock : 0} unidades",
            style: GoogleFonts.getFont(
              FontNames.fontNameP,
              textStyle: TextStyle(fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}
