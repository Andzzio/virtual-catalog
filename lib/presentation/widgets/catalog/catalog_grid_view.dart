import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/filter_catalog_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_card.dart';

class CatalogGridView extends StatefulWidget {
  const CatalogGridView({super.key});

  @override
  State<CatalogGridView> createState() => _CatalogGridViewState();
}

class _CatalogGridViewState extends State<CatalogGridView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FilterCatalogProvider filterCatalogProvider = context
        .watch<FilterCatalogProvider>();
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
                          onPressed: () {},
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
                      onChanged: (value) {
                        filterCatalogProvider.setSearchQuery(value);
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
                  itemCount: filterCatalogProvider.filteredProducts.length,
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
                      product: filterCatalogProvider.filteredProducts[index],
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
