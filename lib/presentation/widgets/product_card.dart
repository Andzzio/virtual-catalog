import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';

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
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.go("/product", extra: widget.product);
        },
        child: Container(
          width: widget.cardWidth,
          decoration: BoxDecoration(color: Colors.transparent),
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(5),
            child: Column(
              children: [
                Expanded(
                  child: widget.isPageView
                      ? Stack(
                          children: [
                            PageView.builder(
                              itemCount: widget.product.imageUrl.length,
                              controller: _pageController,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.asset(
                                        widget.product.imageUrl[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 15,
                                      child: Center(
                                        child: SmoothPageIndicator(
                                          controller: _pageController,
                                          count: widget.product.imageUrl.length,
                                          effect: ExpandingDotsEffect(
                                            activeDotColor: Colors.white,
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
                                        _pageController.page!.toInt() - 1;
                                    if (nextPage < 0) {
                                      nextPage =
                                          widget.product.imageUrl.length - 1;
                                    }
                                    _pageController.animateToPage(
                                      nextPage,
                                      duration: Duration(milliseconds: 300),
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
                                        _pageController.page!.toInt() + 1;
                                    if (nextPage >=
                                        widget.product.imageUrl.length) {
                                      nextPage = 0;
                                    }
                                    _pageController.animateToPage(
                                      nextPage,
                                      duration: Duration(milliseconds: 300),
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

                          child: Image.asset(
                            widget.product.imageUrl.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                SizedBox(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(10),
                    child: Column(
                      children: [
                        Text(
                          widget.product.name,
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(
                              fontSize: 16,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "S/. ${widget.product.variants.first.price}",
                          style: GoogleFonts.getFont(FontNames.fontNameP),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
