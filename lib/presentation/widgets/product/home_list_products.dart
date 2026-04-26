import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_card.dart';

class HomeListProducts extends StatefulWidget {
  final HomeBlock block;
  final List<Product> products;
  const HomeListProducts({
    super.key,
    required this.block,
    required this.products,
  });

  @override
  State<HomeListProducts> createState() => _HomeListProductsState();
}

class _HomeListProductsState extends State<HomeListProducts> {
  final double _cardPadding = 8;
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final activeProducts = widget.products;
    if (activeProducts.isEmpty) return SizedBox.shrink();
    final Size size = MediaQuery.of(context).size;
    final double cardWidth = size.width > 800
        ? ((size.width - 100) / 4.2).clamp(250.0, 350.0)
        : (size.width * 0.4).clamp(180.0, 350.0);
    final double listHeight = cardWidth * (600 / 350);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.block.title,
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(fontSize: size.width < 800 ? 24 : 35),
          ),
        ),
        if (size.width < 800)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.block.subtitle != null) ...[
                Text(
                  widget.block.subtitle!,
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF82868B),
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
              if (widget.block.showButton)
                TextButton(
                  onPressed: () {
                    final String slug = GoRouterState.of(
                      context,
                    ).pathParameters["businessSlug"]!;
                    context.go("/$slug/catalog");
                  },
                  style: ButtonStyle(
                    side: WidgetStatePropertyAll(
                      BorderSide(color: Colors.black),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  child: Text(
                    widget.block.buttonText ?? "Ver todos",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: widget.block.subtitle != null
                      ? Text(
                          widget.block.subtitle!,
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF82868B),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (widget.block.showButton)
                TextButton(
                  onPressed: () {
                    final String slug = GoRouterState.of(
                      context,
                    ).pathParameters["businessSlug"]!;
                    context.go("/$slug/catalog");
                  },
                  style: ButtonStyle(
                    side: WidgetStatePropertyAll(
                      BorderSide(color: Colors.black),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  child: Text(
                    widget.block.buttonText ?? "Ver todos",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
            ],
          ),
        SizedBox(height: 40),
        SizedBox(
          height: listHeight,
          child: Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                itemCount: activeProducts.length,
                itemBuilder: (context, index) {
                  final Product product = activeProducts[index];
                  return Padding(
                    padding: EdgeInsets.all(_cardPadding),
                    child: ProductCard(
                      cardWidth: cardWidth,
                      isPageView: false,
                      product: product,
                    ),
                  );
                },
              ),
              if (size.width >= 800) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    color: Colors.white,
                    disabledColor: Colors.blueGrey,
                    icon: Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () {
                      final double totalCardWidth =
                          cardWidth + (_cardPadding * 2);
                      int currentIndex =
                          (_scrollController.offset / totalCardWidth).round();

                      int targetIndex = currentIndex - 1;
                      if (targetIndex < 0) targetIndex = 0;

                      _scrollController.animateTo(
                        targetIndex * totalCardWidth,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    color: Colors.white,
                    disabledColor: Colors.blueGrey,
                    icon: Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () {
                      final double totalCardWidth =
                          cardWidth + (_cardPadding * 2);

                      int currentIndex =
                          (_scrollController.offset / totalCardWidth).round();

                      int targetIndex = currentIndex + 1;
                      if (targetIndex > activeProducts.length - 1) {
                        targetIndex = activeProducts.length - 1;
                      }

                      _scrollController.animateTo(
                        targetIndex * totalCardWidth,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }
}
