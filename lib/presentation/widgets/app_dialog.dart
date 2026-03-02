import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/filter_catalog_provider.dart'
    show FilterCatalogProvider;
import 'package:virtual_catalog_app/presentation/widgets/product/product_card.dart';

class AppDialog extends StatefulWidget {
  const AppDialog({super.key});

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final filterCatalogProvider = context.watch<FilterCatalogProvider>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 1000,
        height: 800,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: GoogleFonts.getFont(
                FontNames.fontNameP,
                textStyle: TextStyle(),
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: "Buscar...",
                hintStyle: GoogleFonts.getFont(
                  FontNames.fontNameP,
                  textStyle: TextStyle(),
                ),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                filterCatalogProvider.setSearchQuery(value);
              },
              onEditingComplete: () {
                _searchFocusNode.requestFocus();
              },
            ),
            Divider(),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      itemCount:
                          filterCatalogProvider.filteredProducts.length < 8
                          ? filterCatalogProvider.filteredProducts.length
                          : 8,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final Product product =
                            filterCatalogProvider.filteredProducts[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ProductCard(
                            cardWidth: 100,
                            isPageView: false,
                            product: product,
                          ),
                        );
                      },
                    ),
                  ),
                  if (filterCatalogProvider.filteredProducts.length > 8)
                    Positioned(
                      bottom: 15,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 25,
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.black,
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              Colors.white,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            overlayColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.pressed)) {
                                return Colors.grey.shade700;
                              }
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.grey.shade800;
                              }
                              return null;
                            }),
                          ),
                          child: Text(
                            "Ver más",
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.getFont(
                              FontNames.fontNameP,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
