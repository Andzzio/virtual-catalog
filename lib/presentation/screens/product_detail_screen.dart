import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_image_section.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_info_section.dart';
import 'package:virtual_catalog_app/presentation/widgets/whatsapp_floating_button.dart';

class ProductDetailScreen extends StatelessWidget {
  final String? businessSlug;
  final String? productId;
  const ProductDetailScreen({super.key, this.businessSlug, this.productId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ProductProvider productProvider = context.watch<ProductProvider>();
    final Product? product = productProvider.products
        .where((product) => product.id == productId)
        .firstOrNull;

    return Scaffold(
      appBar: CatalogAppBar(isScrolled: true, size: size),
      endDrawer: CartDrawer(),
      floatingActionButton: WhatsappFloatingButton(),
      body: product == null
          ? SingleChildScrollView(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: ProductImageSection(product: product),
                        ),
                        Expanded(
                          flex: 4,
                          child: ProductInfoSection(product: product),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
