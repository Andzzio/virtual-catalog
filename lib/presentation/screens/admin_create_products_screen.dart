import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import '../widgets/admin/products/admin_create_product_form_side.dart';
import '../widgets/admin/products/admin_create_product_info_side.dart';
import '../widgets/admin/products/admin_create_products_media_info.dart';
import '../widgets/admin/products/admin_create_products_table_variants.dart';
import '../widgets/admin/products/admin_create_products_variants_info.dart';
import '../widgets/admin/products/image_picker_uploader.dart';

class AdminCreateProductsScreen extends StatefulWidget {
  const AdminCreateProductsScreen({super.key});

  @override
  State<AdminCreateProductsScreen> createState() =>
      _AdminCreateProductsScreenState();
}

class _AdminCreateProductsScreenState extends State<AdminCreateProductsScreen> {
  List<Map<String, dynamic>> variants = [
    {
      "name": "",
      "sku": "",
      "origPrice": "",
      "discPrice": "",
      "stock": "",
      "sizes": [],
      "colorInt": null,
    },
  ];

  void _addVariant() {
    setState(() {
      variants.add({
        "name": "",
        "sku": "",
        "origPrice": "",
        "discPrice": "",
        "stock": "",
        "sizes": [],
        "colorInt": null,
      });
    });
  }

  void _removeVariant(int index) {
    if (variants.length <= 1) return;
    setState(() {
      if (variants.length > 1 && index >= 0 && index < variants.length) {
        variants.removeAt(index);
      }
    });
  }

  void _updateVariant(int index, String key, dynamic value) {
    setState(() {
      variants[index][key] = value;
    });
  }

  List<Uint8List> selectedImages = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E2E2), height: 1.0),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.save),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
            ),
            label: Text(
              "Guardar Producto",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: AdminCreateProductInfoSide()),
                  SizedBox(width: 30),
                  Expanded(flex: 3, child: AdminCreateProductFormSide()),
                ],
              ),
              SizedBox(height: 30),
              Divider(),
              SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: AdminCreateProductsMediaInfo()),
                  SizedBox(width: 30),
                  Expanded(
                    flex: 3,
                    child: ImagePickerUploader(
                      images: selectedImages,
                      onImagesChanged: (newImages) {
                        setState(() {
                          selectedImages = newImages;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Divider(),
              SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: AdminCreateProductsVariantsInfo(onAdd: _addVariant),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    flex: 3,
                    child: AdminCreateProductsTableVariants(
                      variants: variants,
                      onRemove: _removeVariant,
                      onUpdate: _updateVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
