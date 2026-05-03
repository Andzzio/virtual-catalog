import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_image.dart';

class ProductCard extends StatefulWidget {
  final bool isPageView;
  final double cardWidth;
  final Product product;
  const ProductCard({
    super.key,
    required this.cardWidth,
    required this.isPageView,
    required this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final _pageController = PageController();
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          context.go(
            "/${widget.product.businessId}/product/${widget.product.id}",
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.cardWidth,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorders.radiusCard),
              boxShadow: _isHovered ? [AppShadows.hover] : [AppShadows.soft],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorders.radiusCard),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            width: double.infinity,
                            color: const Color(
                              0xFFF3F4F6,
                            ), // Fondo de unificación premium
                            child: widget.product.imageUrl.isEmpty
                                ? Container(
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 48,
                                      ),
                                    ),
                                  )
                                : widget.isPageView
                                ? Stack(
                                    children: [
                                      PageView.builder(
                                        itemCount:
                                            widget.product.imageUrl.length,
                                        controller: _pageController,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: [
                                              Positioned.fill(
                                                child: CatalogImage(
                                                  optimizedWidth: 400,
                                                  imageUrl: widget
                                                      .product
                                                      .imageUrl[index],
                                                ),
                                              ),
                                              Positioned(
                                                left: 0,
                                                right: 0,
                                                bottom: 15,
                                                child: Center(
                                                  child: SmoothPageIndicator(
                                                    controller: _pageController,
                                                    count: widget
                                                        .product
                                                        .imageUrl
                                                        .length,
                                                    effect: ExpandingDotsEffect(
                                                      activeDotColor:
                                                          Colors.white,
                                                      dotHeight: 10,
                                                      dotWidth: 10,
                                                      spacing: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.arrow_back_ios_rounded,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            if (_pageController.hasClients) {
                                              int nextPage =
                                                  _pageController.page!
                                                      .toInt() -
                                                  1;
                                              if (nextPage < 0) {
                                                nextPage =
                                                    widget
                                                        .product
                                                        .imageUrl
                                                        .length -
                                                    1;
                                              }
                                              _pageController.animateToPage(
                                                nextPage,
                                                duration: Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            if (_pageController.hasClients) {
                                              int nextPage =
                                                  _pageController.page!
                                                      .toInt() +
                                                  1;
                                              if (nextPage >=
                                                  widget
                                                      .product
                                                      .imageUrl
                                                      .length) {
                                                nextPage = 0;
                                              }
                                              _pageController.animateToPage(
                                                nextPage,
                                                duration: Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: CatalogImage(
                                      optimizedWidth: 400,
                                      imageUrl: widget.product.imageUrl.first,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: _buildQuickAddButton(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(AppPaddings.p12),
                      child: Column(
                        children: [
                          Text(
                            widget.product.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              FontNames.fontNameP,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          if (widget.product.variants.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "S/. ${widget.product.variants.first.discountPrice ?? widget.product.variants.first.price}",
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                if (widget
                                        .product
                                        .variants
                                        .first
                                        .discountPrice !=
                                    null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    "S/. ${widget.product.variants.first.price}",
                                    style: GoogleFonts.getFont(
                                      FontNames.fontNameP,
                                      textStyle: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: AppColors.textLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(BuildContext context) {
    final theme = Theme.of(context);
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedScale(
            scale: isHovered ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Material(
              color: isHovered ? AppColors.textDark : theme.primaryColor,
              shape: const CircleBorder(),
              elevation: isHovered ? 8 : 4,
              shadowColor: AppShadows.hover.color,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  if (widget.product.variants.length == 1 &&
                      widget.product.variants.first.stock > 0) {
                    final cartProvider = context.read<CartProvider>();
                    cartProvider.addItem(
                      widget.product,
                      widget.product.variants.first,
                      widget.product.variants.first.sizes.first,
                      1,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Agregado al carrito"),
                        duration: const Duration(seconds: 1),
                        backgroundColor: theme.primaryColor,
                      ),
                    );
                  } else {
                    context.go(
                      "/${widget.product.businessId}/product/${widget.product.id}",
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add_shopping_cart_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
