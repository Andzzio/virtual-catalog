import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/utils/web_meta_utils.dart'
    if (dart.library.js_interop) 'package:virtual_catalog_app/config/utils/web_meta_utils_web.dart'
    if (dart.library.io) 'package:virtual_catalog_app/config/utils/web_meta_utils_stub.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminStickersHangtagsView extends StatefulWidget {
  final String businessSlug;

  const AdminStickersHangtagsView({super.key, required this.businessSlug});

  @override
  State<AdminStickersHangtagsView> createState() =>
      _AdminStickersHangtagsViewState();
}

class _AdminStickersHangtagsViewState extends State<AdminStickersHangtagsView> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<String, bool> _selectedMap = {};
  final Map<String, int> _quantityMap = {};
  final Map<String, String> _selectedSizeMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(widget.businessSlug);
      context.read<BusinessProvider>().loadBusiness(widget.businessSlug);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getStickersToPrint(List<Product> products) {
    final List<Map<String, dynamic>> items = [];
    _selectedMap.forEach((key, isSelected) {
      if (isSelected) {
        final parts = key.split('_');
        final productId = parts[0];
        final variantIndex = int.parse(parts[1]);

        try {
          final product = products.firstWhere((p) => p.id == productId);
          final variant = product.variants[variantIndex];
          final qty = _quantityMap[key] ?? 1;
          final size = _selectedSizeMap[key] ??
              (variant.sizes.isNotEmpty ? variant.sizes.first : "");

          for (int i = 0; i < qty; i++) {
            items.add({
              "name": product.name,
              "sku": variant.sku ?? product.sku ?? "",
              "price": variant.price,
              "size": size,
              "color": variant.name,
              "description": product.description,
            });
          }
        } catch (_) {}
      }
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final businessProvider = context.watch<BusinessProvider>();

    if (productProvider.isLoading || businessProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AdminTheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: AdminTheme.accent),
        ),
      );
    }

    final business = businessProvider.business;
    final products = productProvider.products;
    final query = _searchCtrl.text.toLowerCase().trim();

    final filtered = products.where((p) {
      final matchesName = p.name.toLowerCase().contains(query);
      final matchesSku = p.sku != null && p.sku!.toLowerCase().contains(query);
      final matchesVariantSku = p.variants.any(
        (v) => v.sku != null && v.sku!.toLowerCase().contains(query),
      );
      return matchesName || matchesSku || matchesVariantSku;
    }).toList();

    final stickersToPrint = _getStickersToPrint(products);

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.cardBg,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stickers / Hang-tag',
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Selecciona productos y cantidad de stickers a imprimir.',
              style: AdminTheme.bodySmall(),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: stickersToPrint.isEmpty
                ? null
                : () {
                    if (business != null) {
                      printStickers(stickersToPrint, business);
                    }
                  },
            icon: const Icon(Icons.print),
            style: AdminTheme.primaryButton(),
            label: Text(
              stickersToPrint.isEmpty
                  ? 'Imprimir'
                  : 'Imprimir (${stickersToPrint.length})',
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AdminTheme.border, height: 1.0),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < AdminTheme.breakpointMobile;

          if (isMobile) {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: AdminTheme.accent,
                    labelColor: AdminTheme.textPrimary,
                    unselectedLabelColor: AdminTheme.textSecondary,
                    tabs: [
                      Tab(text: "1. Selección (${filtered.length})"),
                      Tab(text: "2. Previa (${stickersToPrint.length})"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: _buildSelectorSide(filtered),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: _buildPreviewSide(stickersToPrint, business?.name ?? ""),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildSelectorSide(filtered),
                ),
              ),
              Container(width: 1, color: AdminTheme.border),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildPreviewSide(stickersToPrint, business?.name ?? ""),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectorSide(List<Product> list) {
    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (val) => setState(() {}),
          decoration: AdminTheme.inputDecoration(
            hintText: 'Buscar producto por nombre o SKU...',
            prefixIcon: Icon(Icons.search, color: AdminTheme.textMuted),
          ),
          style: GoogleFonts.getFont(FontNames.fontNameH2),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(
                    "No se encontraron productos.",
                    style: TextStyle(color: AdminTheme.textSecondary),
                  ),
                )
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = list[index];
                    return Container(
                      decoration: AdminTheme.cardDecoration(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.getFont(
                              FontNames.fontNameH2,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(product.variants.length, (vIdx) {
                            final variant = product.variants[vIdx];
                            final uniqueKey = "${product.id}_$vIdx";
                            final isSelected = _selectedMap[uniqueKey] ?? false;
                            final quantity = _quantityMap[uniqueKey] ?? 1;

                            if (!_quantityMap.containsKey(uniqueKey)) {
                              _quantityMap[uniqueKey] = 1;
                            }

                            final sizes = variant.sizes;
                            if (sizes.isNotEmpty &&
                                !_selectedSizeMap.containsKey(uniqueKey)) {
                              _selectedSizeMap[uniqueKey] = sizes.first;
                            }

                            return Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AdminTheme.accent.withValues(alpha: 0.05)
                                    : AdminTheme.inputFill,
                                border: Border.all(
                                  color: isSelected
                                      ? AdminTheme.accent
                                      : AdminTheme.border,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: AdminTheme.accent,
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedMap[uniqueKey] = val ?? false;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          variant.name.isEmpty
                                              ? 'Estándar'
                                              : variant.name,
                                          style: GoogleFonts.getFont(
                                            FontNames.fontNameH2,
                                            textStyle: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'SKU: ${variant.sku ?? product.sku ?? "—"} · S/ ${variant.price.toStringAsFixed(2)}',
                                          style: AdminTheme.caption(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (sizes.isNotEmpty) ...[
                                    SizedBox(
                                      width: 80,
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _selectedSizeMap[uniqueKey] ??
                                            sizes.first,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                          border: InputBorder.none,
                                        ),
                                        dropdownColor: AdminTheme.cardBg,
                                        items: sizes.map((s) {
                                          return DropdownMenuItem(
                                            value: s,
                                            child: Text(
                                              s,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AdminTheme.textPrimary),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedSizeMap[uniqueKey] = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (isSelected) ...[
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline,
                                              size: 20),
                                          onPressed: () {
                                            if (quantity > 1) {
                                              setState(() {
                                                _quantityMap[uniqueKey] =
                                                    quantity - 1;
                                              });
                                            }
                                          },
                                        ),
                                        Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline,
                                              size: 20),
                                          onPressed: () {
                                            setState(() {
                                              _quantityMap[uniqueKey] =
                                                  quantity + 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPreviewSide(List<Map<String, dynamic>> items, String businessName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vista Previa',
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AdminTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: items.isEmpty
              ? Container(
                  width: double.infinity,
                  decoration: AdminTheme.cardDecoration(),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Selecciona variantes para visualizar la vista previa de impresión.',
                      style: TextStyle(color: AdminTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 150 / 115,
                        ),
                        itemCount: items.length > 4 ? 4 : items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildStickerPreviewCard(item, businessName);
                        },
                      ),
                    ),
                    if (items.length > 4) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          '+ ${items.length - 4} más se imprimirán',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AdminTheme.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildStickerPreviewCard(Map<String, dynamic> item, String businessName) {
    final name = item["name"] ?? "";
    final sku = item["sku"] ?? "";
    final price = double.tryParse(item["price"].toString()) ?? 0.0;
    final size = item["size"];
    final color = item["color"] ?? "";
    final description = item["description"] ?? "";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            businessName.isEmpty ? 'CRM' : businessName.toUpperCase(),
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            description.isEmpty ? '—' : description,
            style: const TextStyle(
              fontSize: 7,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (size != null && size.toString().isNotEmpty)
                Text(
                  'Talla: $size',
                  style: const TextStyle(fontSize: 7, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              if (color.toString().isNotEmpty)
                Text(
                  'Color: $color',
                  style: const TextStyle(fontSize: 7, color: Colors.black, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          Text(
            'S/ ${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          if (sku.toString().isNotEmpty)
            SizedBox(
              height: 30,
              child: BarcodeWidget(
                barcode: Barcode.code128(),
                data: sku,
                drawText: true,
                style: const TextStyle(color: Colors.black, fontFamily: 'monospace', fontSize: 8),
                color: Colors.black,
              ),
            )
          else
            const SizedBox(
              height: 30,
              child: Center(
                child: Text('SIN SKU', style: TextStyle(fontSize: 8, color: Colors.black38)),
              ),
            ),
        ],
      ),
    );
  }
}
