import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/filter_catalog.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_card.dart';

class AppDialog extends StatefulWidget {
  const AppDialog({super.key});

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = "";
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final allProducts = context.watch<ProductProvider>().products;
    final filtered = FilterCatalog.filterProducts(allProducts, search: _query);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: isMobile ? size.width * 0.95 : 1000,
        height: isMobile ? size.height * 0.8 : 800,
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
                setState(() => _query = value);
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
                      itemCount: filtered.length < 8 ? filtered.length : 8,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 4,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final Product product = filtered[index];
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
                  if (filtered.length > 8 && _query.isNotEmpty)
                    Positioned(
                      bottom: 15,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            final uri = GoRouter.of(
                              context,
                            ).routeInformationProvider.value.uri;
                            final slug = uri.pathSegments.isNotEmpty
                                ? uri.pathSegments.first
                                : null;
                            Navigator.pop(context);
                            context.go(
                              FilterCatalog.buildCatalogUrl(
                                slug,
                                search: _query,
                              ),
                            );
                          },
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
