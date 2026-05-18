import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/config/routers/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
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
    return Container(
      width: double.infinity,
      decoration: AdminTheme.cardDecoration(),
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
            return const Center(
              child: CircularProgressIndicator(color: AdminTheme.accent),
            );
          }

          if (products.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                // Skill: Use LayoutBuilder for responsive decisions
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile =
                        constraints.maxWidth < AdminTheme.breakpointMobile;

                    if (isMobile) {
                      return _buildMobileProductCards(paginatedProducts);
                    }
                    return _buildDesktopTable(paginatedProducts);
                  },
                ),
              ),
              Divider(height: 1, color: AdminTheme.border),
              _buildPagination(products.length, paginatedProducts.length),
            ],
          );
        },
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AdminTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              "No tienes productos aún",
              style: AdminTheme.heading2().copyWith(
                color: AdminTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Crea tu primer producto para empezar a vender.",
              style: AdminTheme.bodySmall(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mobile: Card list with edit/delete ───────────────
  Widget _buildMobileProductCards(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final totalStock = product.variants.fold(0, (sum, v) => sum + v.stock);
        final price = product.variants.isNotEmpty
            ? "S/ ${product.variants.first.price.toStringAsFixed(2)}"
            : "S/ 0.00";

        return GestureDetector(
          onTap: () => _showProductDetails(context, product),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AdminTheme.cardBg,
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CatalogImage(
                    imageUrl: product.imageUrl.isNotEmpty
                        ? product.imageUrl.first
                        : "",
                    width: 56,
                    height: 56,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AdminTheme.body().copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${product.category} · Stock: $totalStock",
                        style: AdminTheme.caption(),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            price,
                            style: AdminTheme.body().copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.isAvailable ? "Activo" : "Inactivo",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: product.isAvailable
                                    ? AdminTheme.success
                                    : AdminTheme.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Edit/Delete actions for mobile
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      NavigationHelper.go(context, 
                        "/${widget.businessSlug}/admin/products/edit/${product.id}",
                      );
                    } else if (value == 'delete') {
                      _confirmDelete(context, product.id, product.name);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text("Editar", style: AdminTheme.body()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AdminTheme.danger,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Eliminar",
                            style: AdminTheme.body().copyWith(
                              color: AdminTheme.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Desktop: DataTable with horizontal scroll ────────
  Widget _buildDesktopTable(List<Product> paginatedProducts) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width > 800
                ? MediaQuery.sizeOf(context).width -
                      AdminTheme.sidebarWidth -
                      60
                : MediaQuery.sizeOf(context).width - 60,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
            child: DataTable(
              showCheckboxColumn: false,
              dataRowMinHeight: 65,
              dataRowMaxHeight: 75,
              dividerThickness: 3,
              headingRowColor: WidgetStateProperty.all(
                AdminTheme.cardBgElevated,
              ),
              columns: [
                _col("IMAGEN"),
                _col("NOMBRE"),
                _col("CATEGORÍA"),
                _col("STOCK"),
                _col("PRECIO"),
                _col("ESTADO"),
                _col("ACCIONES"),
              ],
              rows: paginatedProducts.map((product) {
                return DataRow(
                  onSelectChanged: (value) =>
                      _showProductDetails(context, product),
                  color: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return AdminTheme.cardBgElevated;
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
                            style: GoogleFonts.getFont(FontNames.fontNameH2),
                          ),
                          if (product.sku != "" && product.sku != null)
                            Text(
                              product.sku!,
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  color: AdminTheme.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        product.category,
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${product.variants.fold(0, (sum, v) => sum + v.stock)}",
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                    ),
                    DataCell(
                      Text(() {
                        if (product.variants.isEmpty) {
                          return "S/ 0.00";
                        }
                        final prices = product.variants.map((v) => v.price);
                        final minPrice = prices.reduce(
                          (value, element) => value < element ? value : element,
                        );
                        final maxPrice = prices.reduce(
                          (value, element) => value > element ? value : element,
                        );
                        if (minPrice == maxPrice) {
                          return "S/ ${minPrice.toStringAsFixed(2)}";
                        }
                        return "S/ ${minPrice.toStringAsFixed(2)} - ${maxPrice.toStringAsFixed(2)}";
                      }(), style: GoogleFonts.getFont(FontNames.fontNameH2)),
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
                            await context.read<ProductProvider>().updateProduct(
                              widget.businessSlug,
                              updatedProduct,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                        activeThumbColor: AdminTheme.accent,
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              onPressed: () {
                                NavigationHelper.go(context, 
                                  "/${widget.businessSlug}/admin/products/edit/${product.id}",
                                );
                              },
                              icon: Icon(Icons.edit_outlined, size: 20),
                              tooltip: "Editar producto",
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              onPressed: () => _confirmDelete(
                                context,
                                product.id,
                                product.name,
                              ),
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: AdminTheme.danger,
                              ),
                              tooltip: "Eliminar producto",
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
    );
  }

  // ─── Pagination ───────────────────────────────────────
  Widget _buildPagination(int totalCount, int visibleCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < AdminTheme.breakpointMobile;

          if (isMobile) {
            return Column(
              children: [
                Text(
                  "Mostrando ${currentPage * itemsPerPage + 1} - ${currentPage * itemsPerPage + visibleCount}  de $totalCount productos",
                  style: AdminTheme.caption(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: currentPage > 0
                            ? () => setState(() => currentPage--)
                            : null,
                        style: AdminTheme.outlinedButton(),
                        child: Text(
                          "Anterior",
                          style: GoogleFonts.getFont(FontNames.fontNameH2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (currentPage + 1) * itemsPerPage < totalCount
                            ? () => setState(() => currentPage++)
                            : null,
                        style: AdminTheme.primaryButton(),
                        child: Text(
                          "Siguiente",
                          style: GoogleFonts.getFont(FontNames.fontNameH2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Text(
                "Mostrando ${currentPage * itemsPerPage + 1} - ${currentPage * itemsPerPage + visibleCount}  de $totalCount productos",
                style: GoogleFonts.getFont(FontNames.fontNameH2),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: currentPage > 0
                    ? () => setState(() => currentPage--)
                    : null,
                style: AdminTheme.outlinedButton(),
                child: Text(
                  "Anterior",
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: (currentPage + 1) * itemsPerPage < totalCount
                    ? () => setState(() => currentPage++)
                    : null,
                style: AdminTheme.primaryButton(),
                child: Text(
                  "Siguiente",
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  DataColumn _col(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AdminTheme.textSecondary,
          ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTheme.radiusLg),
        ),
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
              backgroundColor: AdminTheme.danger,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTheme.radiusLg),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AdminTheme.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Detalles del Producto", style: AdminTheme.heading2()),
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
                      // Skill: LayoutBuilder for responsive dialog
                      LayoutBuilder(
                        builder: (ctx, dialogConstraints) {
                          if (dialogConstraints.maxWidth < 400) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProductImage(product),
                                const SizedBox(height: 16),
                                _buildProductInfo(product),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProductImage(product),
                              const SizedBox(width: 24),
                              Expanded(child: _buildProductInfo(product)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Descripción",
                        style: AdminTheme.body().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(color: AdminTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Variantes (${product.variants.length})",
                        style: AdminTheme.body().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...product.variants.map(
                        (v) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AdminTheme.surface,
                            borderRadius: BorderRadius.circular(
                              AdminTheme.radiusMd,
                            ),
                            border: Border.all(color: AdminTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      v.name.isEmpty ? "Variante base" : v.name,
                                      style: AdminTheme.body().copyWith(
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
                                            ? AdminTheme.success
                                            : AdminTheme.danger,
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
                                        backgroundColor: AdminTheme.cardBg,
                                        label: Text(s),
                                        side: BorderSide(
                                          color: AdminTheme.border,
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

  Widget _buildProductImage(Product product) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        border: Border.all(color: AdminTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        child: product.imageUrl.isNotEmpty
            ? Image.network(product.imageUrl.first, fit: BoxFit.cover)
            : Icon(
                Icons.image_not_supported,
                size: 50,
                color: AdminTheme.textMuted,
              ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: AdminTheme.heading1()),
        const SizedBox(height: 8),
        _buildDetailRow("Categoría:", product.category),
        if (product.sku != null) _buildDetailRow("SKU:", product.sku!),
        _buildDetailRow("Estado:", product.isAvailable ? "Activo" : "Inactivo"),
        _buildDetailRow(
          "Precio:",
          "S/. ${product.variants.first.price.toStringAsFixed(2)}",
        ),
      ],
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
