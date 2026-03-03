import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/filter_catalog.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog/catalog_grid_view.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog/filter_catalog_view.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/menu_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/whatsapp_floating_button.dart';

class CatalogScreen extends StatelessWidget {
  final String? initialSearch;
  final String? initialCategory;
  final String? initialSort;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final Set<String>? initialSizes;
  final bool? initialAvailable;

  const CatalogScreen({
    super.key,
    this.initialSearch,
    this.initialCategory,
    this.initialSort,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialSizes,
    this.initialAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final allProducts = context.watch<ProductProvider>().products;
    final filtered = FilterCatalog.filterProducts(
      allProducts,
      search: initialSearch,
      category: initialCategory,
      sort: initialSort,
      minPrice: initialMinPrice,
      maxPrice: initialMaxPrice,
      sizes: initialSizes,
      available: initialAvailable,
    );
    final categories = FilterCatalog.extractCategories(allProducts);
    final sizes = FilterCatalog.extractSizes(allProducts);
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: CatalogAppBar(
        isScrolled: true,
        size: size,
        inCatalogScreen: true,
      ),
      floatingActionButton: WhatsappFloatingButton(),
      endDrawer: CartDrawer(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (size.width > 1100)
            Expanded(
              flex: 3,
              child: FilterCatalogView(
                search: initialSearch,
                selectedCategory: initialCategory ?? "Todos",
                selectedOrder: initialSort ?? "Relevantes",
                minPrice: initialMinPrice ?? 0,
                maxPrice: initialMaxPrice ?? 0,
                selectedSizes: initialSizes ?? {},
                isAvailable: initialAvailable ?? false,
                categories: categories,
                sizes: sizes,
              ),
            ),
          Expanded(
            flex: 10,
            child: CatalogGridView(
              products: filtered,
              search: initialSearch,
              selectedCategory: initialCategory,
              selectedOrder: initialSort,
              minPrice: initialMinPrice,
              maxPrice: initialMaxPrice,
              selectedSizes: initialSizes,
              isAvailable: initialAvailable,
              categories: categories,
              sizes: sizes,
            ),
          ),
        ],
      ),
    );
  }
}
