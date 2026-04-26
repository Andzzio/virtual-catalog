import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_image.dart';

class HomeMosaicProducts extends StatelessWidget {
  final HomeBlock block;
  final List<Product> products;

  const HomeMosaicProducts({
    super.key,
    required this.block,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title.isNotEmpty) ...[
          Text(
            block.title,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: isMobile ? 24 : 35),
            ),
          ),
          if (isMobile) const SizedBox(height: 8),
        ],
        if (block.subtitle != null && block.subtitle!.isNotEmpty) ...[
          Text(
            block.subtitle!,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFF82868B),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (!isMobile && block.title.isNotEmpty && block.subtitle == null)
          const SizedBox(height: 20),
        if (isMobile) _buildMobileView() else _buildDesktopView(),
        if (block.showButton && block.buttonText != null) ...[
          const SizedBox(height: 30),
          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: Text(
                block.buttonText!,
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopView() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 950),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final leftWidth = (totalWidth - 15) * 2 / 3;
            final leftHeight = leftWidth / 0.65;

            if (products.length == 1) {
              return SizedBox(
                height: leftHeight,
                width: double.infinity,
                child: _MosaicTile(product: products[0]),
              );
            }

            if (products.length == 2) {
              return SizedBox(
                height: leftHeight,
                child: Row(
                  children: [
                    Expanded(flex: 2, child: _MosaicTile(product: products[0])),
                    const SizedBox(width: 15),
                    Expanded(flex: 1, child: _MosaicTile(product: products[1])),
                  ],
                ),
              );
            }

            return SizedBox(
              height: leftHeight,
              child: Row(
                children: [
                  Expanded(flex: 2, child: _MosaicTile(product: products[0])),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(child: _MosaicTile(product: products[1])),
                        const SizedBox(height: 15),
                        Expanded(child: _MosaicTile(product: products[2])),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: products.take(3).map((product) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: SizedBox(
            height: 350,
            width: double.infinity,
            child: _MosaicTile(product: product),
          ),
        );
      }).toList(),
    );
  }
}

class _MosaicTile extends StatelessWidget {
  final Product product;

  const _MosaicTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final price = product.variants.isNotEmpty
        ? product.variants.first.price
        : 0.0;
    final discountPrice = product.variants.isNotEmpty
        ? product.variants.first.discountPrice
        : null;
    final currentPrice = discountPrice ?? price;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go("/${product.businessId}/product/${product.id}");
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Positioned.fill(
                child: CatalogImage(
                  imageUrl: product.imageUrl.isNotEmpty
                      ? product.imageUrl.first
                      : "",
                  optimizedWidth: 800,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.getFont(
                        FontNames.fontNameP,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "S/. $currentPrice",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameP,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (discountPrice != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            "S/. $price",
                            style: GoogleFonts.getFont(
                              FontNames.fontNameP,
                              textStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
