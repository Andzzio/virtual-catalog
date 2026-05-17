import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

import 'admin_product_table.dart';

class AdminProductsView extends StatefulWidget {
  final String businessSlug;
  const AdminProductsView({super.key, required this.businessSlug});

  @override
  State<AdminProductsView> createState() => _AdminProductsViewState();
}

class _AdminProductsViewState extends State<AdminProductsView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.cardBg,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AdminTheme.border, height: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Productos",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "Administra tu inventario de prendas y artículos.",
              style: AdminTheme.bodySmall(),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              context.go("/${widget.businessSlug}/admin/products/create");
            },
            icon: Icon(Icons.add),
            style: AdminTheme.primaryButton(),
            label: Text(
              "Crear Producto",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: AdminTheme.cardDecoration(),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (value) => setState(() {}),
                decoration: AdminTheme.inputDecoration(
                  hintText: "Buscar productos por nombre o SKU...",
                  prefixIcon: Icon(Icons.search, color: AdminTheme.textMuted),
                ),
                style: GoogleFonts.getFont(FontNames.fontNameH2),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: AdminProductTable(
                businessSlug: widget.businessSlug,
                searchQuery: _searchCtrl.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
