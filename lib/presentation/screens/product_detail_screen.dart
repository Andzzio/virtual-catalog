import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/menu_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_card.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_image_section.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_info_section.dart';
import 'package:virtual_catalog_app/presentation/widgets/whatsapp_floating_button.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_footer.dart';

class ProductDetailScreen extends StatelessWidget {
  final String? businessSlug;
  final String? productId;
  const ProductDetailScreen({super.key, this.businessSlug, this.productId});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final size = MediaQuery.of(context).size;
    final ProductProvider productProvider = context.watch<ProductProvider>();
    final Product? product = productProvider.products
        .where((product) => product.id == productId && product.isAvailable)
        .firstOrNull;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: MenuDrawer(),
      appBar: CatalogAppBar(
        isScrolled: true,
        size: size,
        inCatalogScreen: false,
      ),
      endDrawer: CartDrawer(),
      floatingActionButton: WhatsappFloatingButton(),
      body: product == null
          ? Center(
              child: productProvider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Producto no encontrado o no disponible."),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(top: 65),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: isMobile
                        ? Column(
                            children: [
                              ProductImageSection(product: product),
                              ProductInfoSection(product: product),
                            ],
                          )
                        : Row(
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
                  if (productProvider.products
                      .where((p) => p.id != productId && p.isAvailable)
                      .isNotEmpty) ...[
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "También te puede interesar",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(
                              fontSize: 22,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 380,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: productProvider.products
                            .where((p) => p.id != productId && p.isAvailable)
                            .take(5)
                            .map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: ProductCard(
                                  cardWidth: 260,
                                  isPageView: false,
                                  product: p,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 60),
                  const CatalogFooter(),
                ],
              ),
            ),
    );
  }
}
