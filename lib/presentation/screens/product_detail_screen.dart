import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/product_image_section.dart';
import 'package:virtual_catalog_app/presentation/widgets/product_info_section.dart';
import 'package:virtual_catalog_app/presentation/widgets/whatsapp_floating_button.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CatalogAppBar(isScrolled: true, size: size),
      floatingActionButton: WhatsappFloatingButton(),
      body: SingleChildScrollView(
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
