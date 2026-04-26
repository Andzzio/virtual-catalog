import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_image.dart';

class AdminProductTable extends StatefulWidget {
  final String businessSlug;
  final String searchQuery;
  const AdminProductTable({
    super.key,
    required this.businessSlug,
    this.searchQuery = "",
  });

  @override
  State<AdminProductTable> createState() => _AdminProductTableState();
}

class _AdminProductTableState extends State<AdminProductTable> {
  int currentPage = 0;
  int itemsPerPage = 10;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Material(
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: size.height * 0.65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFE2E2E2)),
        ),
        child: Consumer<ProductProvider>(
          builder: (context, value, child) {
            final products = value.products.where((p) {
              if (widget.searchQuery.isEmpty) return true;
              return p.name.toLowerCase().contains(
                    widget.searchQuery.toLowerCase(),
                  ) ||
                  (p.sku?.toLowerCase().contains(
                        widget.searchQuery.toLowerCase(),
                      ) ??
                      false);
            }).toList();
            final paginatedProducts = products
                .skip(currentPage * itemsPerPage)
                .take(itemsPerPage)
                .toList();
            if (value.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: DataTable(
                        showCheckboxColumn: false,
                        dataRowMinHeight: 65,
                        dataRowMaxHeight: 75,
                        headingRowColor: WidgetStateProperty.all(
                          Color(0xfff8f9fa),
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              "IMAGEN",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "NOMBRE",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "CATEGORÍA",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "STOCK",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "PRECIO",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "ESTADO",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "ACCIONES",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                        ],
                        rows: paginatedProducts.map((product) {
                          return DataRow(
                            onSelectChanged: (value) =>
                                _showProductDetails(context, product),
                            color: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.grey[50];
                              }
                              return null;
                            }),
                            cells: [
                              DataCell(
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CatalogImage(
                                    imageUrl: product.imageUrl.isNotEmpty
                                        ? product.imageUrl.first
                                        : "",
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      product.name,
                                      style: GoogleFonts.getFont(
                                        FontNames.fontNameH2,
                                      ),
                                    ),
                                    if (product.sku != "" &&
                                        product.sku != null)
                                      Text(
                                        product.sku!,
                                        style: GoogleFonts.getFont(
                                          FontNames.fontNameH2,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  product.category,
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${product.variants.fold(0, (sum, v) => sum + v.stock)}",
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  () {
                                    if (product.variants.isEmpty) {
                                      return "S/ 0.00";
                                    }
                                    final prices = product.variants.map(
                                      (v) => v.price,
                                    );
                                    final minPrice = prices.reduce(
                                      (value, element) =>
                                          value < element ? value : element,
                                    );
                                    final maxPrice = prices.reduce(
                                      (value, element) =>
                                          value > element ? value : element,
                                    );
                                    if (minPrice == maxPrice) {
                                      return "S/ ${minPrice.toStringAsFixed(2)}";
                                    }
                                    return "S/ ${minPrice.toStringAsFixed(2)} - ${maxPrice.toStringAsFixed(2)}";
                                  }(),
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                  ),
                                ),
                              ),
                              DataCell(
                                Switch(
                                  value: product.isAvailable,
                                  onChanged: (value) async {
                                    try {
                                      final updatedProduct = Product(
                                        id: product.id,
                                        name: product.name,
                                        description: product.description,
                                        imageUrl: product.imageUrl,
                                        businessId: product.businessId,
                                        createdAt: product.createdAt,
                                        updatedAt: product.updatedAt,
                                        category: product.category,
                                        variants: product.variants,
                                        sku: product.sku,
                                        isAvailable: value,
                                      );
                                      await context
                                          .read<ProductProvider>()
                                          .updateProduct(
                                            widget.businessSlug,
                                            updatedProduct,
                                          );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  },
                                  activeThumbColor: Colors.black,
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        context.go(
                                          "/${widget.businessSlug}/admin/products/edit/${product.id}",
                                        );
                                      },
                                      icon: Icon(Icons.edit, size: 20),
                                    ),
                                    IconButton(
                                      onPressed: () => _confirmDelete(
                                        context,
                                        product.id,
                                        product.name,
                                      ),
                                      icon: Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        "Mostrando ${currentPage * itemsPerPage + 1} - ${(currentPage * itemsPerPage + paginatedProducts.length)}  de ${products.length} productos",
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                      Spacer(),
                      OutlinedButton(
                        onPressed: currentPage > 0
                            ? () => setState(() => currentPage--)
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          side: BorderSide(color: Color(0xFFE2E2E2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                        child: Text(
                          "Anterior",
                          style: GoogleFonts.getFont(FontNames.fontNameH2),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            (currentPage + 1) * itemsPerPage < products.length
                            ? () => setState(() => currentPage++)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                        child: Text(
                          "Siguiente",
                          style: GoogleFonts.getFont(FontNames.fontNameH2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String productId,
    String productName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Eliminar Producto",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Text(
          "¿Estás seguro de que deseas eliminar \"$productName\"?",
          style: GoogleFonts.getFont(FontNames.fontNameH2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              "Cancelar",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Eliminar",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<ProductProvider>().deleteProduct(
        widget.businessSlug,
        productId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Producto eliminado")));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  Future<void> _showProductDetails(
    BuildContext context,
    Product product,
  ) async {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E2E2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Detalles del Producto",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Images
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE2E2E2),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl.first,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                    textStyle: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow("Categoría:", product.category),
                                if (product.sku != null)
                                  _buildDetailRow("SKU:", product.sku!),
                                _buildDetailRow(
                                  "Estado:",
                                  product.isAvailable ? "Activo" : "Inactivo",
                                ),
                                _buildDetailRow(
                                  "Precio:",
                                  "S/. ${product.variants.first.price.toStringAsFixed(2)}",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Descripción",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(color: Colors.grey[800]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Variantes (${product.variants.length})",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...product.variants.map(
                        (v) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E2E2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    v.name.isEmpty ? "Variante base" : v.name,
                                    style: GoogleFonts.getFont(
                                      FontNames.fontNameH2,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Stock: ${v.stock}",
                                    style: GoogleFonts.getFont(
                                      FontNames.fontNameH2,
                                      textStyle: TextStyle(
                                        color: v.stock > 0
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                "Precio:",
                                "S/. ${v.price.toStringAsFixed(2)}",
                              ),
                              if ((v.discountPrice ?? 0) > 0)
                                _buildDetailRow(
                                  "Precio Descuento:",
                                  "S/. ${v.discountPrice?.toStringAsFixed(2)}",
                                ),
                              if (v.sku != null)
                                _buildDetailRow("SKU:", v.sku!),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: v.sizes
                                    .map(
                                      (s) => Chip(
                                        backgroundColor: Colors.white,
                                        label: Text(s),
                                        side: const BorderSide(
                                          color: Color(0xFFE2E2E2),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
        ],
      ),
    );
  }
}
