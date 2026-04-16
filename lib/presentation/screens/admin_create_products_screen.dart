import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/data/services/cloudinary_service.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import '../widgets/admin/products/admin_create_product_form_side.dart';
import '../widgets/admin/products/admin_create_product_info_side.dart';
import '../widgets/admin/products/admin_create_products_media_info.dart';
import '../widgets/admin/products/admin_create_products_table_variants.dart';
import '../widgets/admin/products/admin_create_products_variants_info.dart';
import '../widgets/admin/products/image_picker_uploader.dart';

class AdminCreateProductsScreen extends StatefulWidget {
  final Product? product;
  const AdminCreateProductsScreen({super.key, this.product});

  @override
  State<AdminCreateProductsScreen> createState() =>
      _AdminCreateProductsScreenState();
}

class _AdminCreateProductsScreenState extends State<AdminCreateProductsScreen> {
  final CloudinaryService _cloudinary = CloudinaryService();

  final _formKey = GlobalKey<FormState>();

  late String productName;
  late String category;
  late String productSku;
  late String description;
  List<dynamic> mediaItems = [];
  late List<Map<String, dynamic>> variants;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      productName = p.name;
      category = p.category;
      productSku = p.sku ?? "";
      description = p.description;
      mediaItems = List<dynamic>.from(p.imageUrl);
      variants = p.variants
          .map(
            (v) => <String, dynamic>{
              "name": v.name,
              "sku": v.sku ?? "",
              "origPrice": v.price.toString(),
              "discountPrice": v.discountPrice.toString(),
              "stock": v.stock.toString(),
              "sizes": List<String>.from(v.sizes),
              "colorInt": v.color,
            },
          )
          .toList();
    } else {
      productName = "";
      category = "";
      productSku = "";
      description = "";
      mediaItems = [];
      variants = [
        {
          "name": "",
          "sku": "",
          "origPrice": "",
          "discountPrice": "",
          "stock": "",
          "sizes": [],
          "colorInt": Colors.blueAccent.toARGB32(),
        },
      ];
    }
  }

  void _addVariant() {
    setState(() {
      variants.add({
        "name": "",
        "sku": "",
        "origPrice": "",
        "discountPrice": "",
        "stock": "",
        "sizes": [],
        "colorInt": Colors.blueAccent.toARGB32(),
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

  Future<void> _saveProduct() async {
    final business = context.read<BusinessProvider>().business;
    if (business == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(child: CircularProgressIndicator(color: Colors.black)),
      );

      List<String> finalUrls = List.filled(mediaItems.length, "");
      List<Future<void>> uploadTasks = [];

      for (int i = 0; i < mediaItems.length; i++) {
        final item = mediaItems[i];
        if (item is String) {
          finalUrls[i] = item;
        } else if (item is Uint8List) {
          final fileName =
              "prod_${business.slug}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg";
          uploadTasks.add(() async {
            final result = await _cloudinary.uploadImage(item, fileName);
            finalUrls[i] = result["url"]!;
          }());
        }
      }
      await Future.wait(uploadTasks);

      final product = Product(
        id: isEditing ? widget.product!.id : "",
        name: productName,
        description: description,
        imageUrl: finalUrls,
        businessId: business.slug,
        createdAt: isEditing ? widget.product!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        category: category,
        sku: productSku.isEmpty ? null : productSku,
        variants: variants
            .map(
              (v) => ProductVariant(
                name: v["name"],
                sku: v["sku"].toString().isEmpty ? null : v["sku"],
                price: double.tryParse(v["origPrice"].toString()) ?? 0.0,
                discountPrice:
                    double.tryParse(v["discountPrice"].toString()) ?? 0.0,
                stock: int.tryParse(v["stock"].toString()) ?? 0,
                sizes: List<String>.from(v["sizes"]),
                color: v["colorInt"],
              ),
            )
            .toList(),
      );

      if (!mounted) return;

      if (isEditing) {
        await context.read<ProductProvider>().updateProduct(
          business.slug,
          product,
        );
      } else {
        await context.read<ProductProvider>().addProduct(
          business.slug,
          product,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      context.pop(); // Go back to products list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? "✅ ¡Producto actualizado!"
                : "✅ ¡Producto creado con éxito!",
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error crítico: $e")));
    }
  }

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
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              if (mediaItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Selecciona al menos una imagen")),
                );
                return;
              }

              final hasVariantWithoutSizes = variants.any(
                (v) => (v["sizes"] as List).isEmpty,
              );

              if (hasVariantWithoutSizes) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Cada variante debe tener al menos una talla",
                    ),
                  ),
                );
                return;
              }

              _saveProduct();
            },
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
              isEditing ? "Guardar Cambios" : "Guardar Producto",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 900
              ? 150.0
              : (constraints.maxWidth > 600 ? 40.0 : 16.0);
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1, child: AdminCreateProductInfoSide()),
                        SizedBox(width: 30),
                        Expanded(
                          flex: 3,
                          child: AdminCreateProductFormSide(
                            initialName: isEditing ? productName : null,
                            initialCategory: isEditing ? category : null,
                            initialSku: isEditing ? productSku : null,
                            initialDescription: isEditing ? description : null,
                            onNameChanged: (val) =>
                                setState(() => productName = val),
                            onCategoryChanged: (val) =>
                                setState(() => category = val),
                            onSkuChanged: (val) =>
                                setState(() => productSku = val),
                            onDescriptionChanged: (val) =>
                                setState(() => description = val),
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
                          child: AdminCreateProductsMediaInfo(),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          flex: 3,
                          child: ImagePickerUploader(
                            mediaItems: mediaItems,
                            onMediaChanged: (newMedia) {
                              setState(() {
                                mediaItems = newMedia;
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
                          child: AdminCreateProductsVariantsInfo(
                            onAdd: _addVariant,
                          ),
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
        },
      ),
    );
  }
}
