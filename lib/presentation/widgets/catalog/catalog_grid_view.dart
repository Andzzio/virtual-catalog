import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_card.dart';

class CatalogGridView extends StatelessWidget {
  const CatalogGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider = context.watch<ProductProvider>();
    return Container(
      padding: EdgeInsets.all(20),
      constraints: BoxConstraints(maxWidth: 1200),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            shrinkWrap: true,
            itemCount: productProvider.products.length,
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
                product: productProvider.products[index],
              );
            },
          );
        },
      ),
    );
  }
}
