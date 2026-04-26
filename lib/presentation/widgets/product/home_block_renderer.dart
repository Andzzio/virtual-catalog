import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/home_grid_products.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/home_list_products.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/home_mosaic_products.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/home_featured_product.dart';

class HomeBlockRenderer extends StatelessWidget {
  final HomeBlock block;
  final List<Product> products;

  const HomeBlockRenderer({
    super.key,
    required this.block,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    switch (block.layout) {
      case BlockLayout.list:
        return HomeListProducts(block: block, products: products);
      case BlockLayout.grid:
        return HomeGridProducts(block: block, products: products);
      case BlockLayout.mosaic:
        return HomeMosaicProducts(block: block, products: products);
      case BlockLayout.featured:
        return HomeFeaturedProduct(block: block, product: products.first);
    }
  }
}
