import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_card.dart';

class HomeListProducts extends StatefulWidget {
  final ProductProvider provider;
  const HomeListProducts({super.key, required this.provider});

  @override
  State<HomeListProducts> createState() => _HomeListProductsState();
}

class _HomeListProductsState extends State<HomeListProducts> {
  final double _listHeight = 600;
  final double _cardWidth = 350;
  final double _cardPadding = 8;
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nuestros productos más vendidos",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(fontSize: 35),
          ),
        ),
        Row(
          children: [
            Text(
              "Piezas atemporales diseñadas para el guardarropa moderno",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: TextStyle(fontSize: 16, color: Color(0xFF82868B)),
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                side: WidgetStatePropertyAll(BorderSide(color: Colors.black)),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              child: Text(
                "Ver todos",
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
          height: _listHeight,
          child: Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                itemCount: widget.provider.products.length >= 10
                    ? 10
                    : widget.provider.products.length,
                itemBuilder: (context, index) {
                  final Product product = widget.provider.products[index];
                  return Padding(
                    padding: EdgeInsets.all(_cardPadding),
                    child: ProductCard(
                      cardWidth: _cardWidth,
                      isPageView: false,
                      product: product,
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  color: Colors.white,
                  disabledColor: Colors.blueGrey,
                  icon: Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () {
                    final double totalCardWidth =
                        _cardWidth + (_cardPadding * 2);
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
                        _cardWidth + (_cardPadding * 2);

                    int currentIndex =
                        (_scrollController.offset / totalCardWidth).round();

                    int targetIndex = currentIndex + 1;
                    if (targetIndex > 9) targetIndex = 9;

                    _scrollController.animateTo(
                      targetIndex * totalCardWidth,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
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
