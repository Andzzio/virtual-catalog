import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/utils/filter_catalog.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog/filter_catalog_view.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_card.dart';

class CatalogGridView extends StatefulWidget {
  final List<Product> products;
  final String? search;
  final String? selectedCategory;
  final String? selectedOrder;
  final double? minPrice;
  final double? maxPrice;
  final Set<String>? selectedSizes;
  final bool? isAvailable;
  final List<String> categories;
  final List<String> sizes;
  const CatalogGridView({
    super.key,
    required this.products,
    this.search,
    this.selectedCategory,
    this.selectedOrder,
    this.minPrice,
    this.maxPrice,
    this.selectedSizes,
    this.isAvailable,
    required this.categories,
    required this.sizes,
  });

  @override
  State<CatalogGridView> createState() => _CatalogGridViewState();
}

class _CatalogGridViewState extends State<CatalogGridView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  size.width < 1100
                      ? IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: 0.7,
                                maxChildSize: 0.9,
                                minChildSize: 0.4,
                                builder: (_, _) {
                                  return FilterCatalogView(
                                    search: widget.search,
                                    selectedCategory:
                                        widget.selectedCategory ?? "Todos",
                                    selectedOrder:
                                        widget.selectedOrder ?? "Relevantes",
                                    minPrice: widget.minPrice ?? 0,
                                    maxPrice: widget.maxPrice ?? 0,
                                    selectedSizes: widget.selectedSizes ?? {},
                                    isAvailable: widget.isAvailable ?? false,
                                    categories: widget.categories,
                                    sizes: widget.sizes,
                                  );
                                },
                              ),
                            );
                          },
                          icon: Icon(Icons.filter_alt),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 43,
                    width: (size.width * 0.2).clamp(250, 500),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: GoogleFonts.getFont(
                        FontNames.fontNameP,
                        textStyle: TextStyle(),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: "Buscar...",
                        hintStyle: GoogleFonts.getFont(
                          FontNames.fontNameP,
                          textStyle: TextStyle(),
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {},
                      onSubmitted: (value) {
                        final slug = GoRouterState.of(
                          context,
                        ).pathParameters["businessSlug"];
                        context.replace(
                          FilterCatalog.buildCatalogUrl(
                            slug,
                            search: value,
                            category: widget.selectedCategory,
                            sort: widget.selectedOrder,
                            minPrice: widget.minPrice,
                            maxPrice: widget.maxPrice,
                            sizes: widget.selectedSizes,
                            available: widget.isAvailable,
                          ),
                        );
                      },
                      onEditingComplete: () {
                        _searchFocusNode.requestFocus();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: widget.products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 700 ? 4 : 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.6,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(
                      cardWidth: 300,
                      isPageView: false,
                      product: widget.products[index],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
