import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/widgets/product_card.dart';

class HomeListProducts extends StatefulWidget {
  const HomeListProducts({super.key});

  @override
  State<HomeListProducts> createState() => _HomeListProductsState();
}

class _HomeListProductsState extends State<HomeListProducts> {
  final double _listHeight = 600;
  final double _cardWidth = 300;
  final double _cardPadding = 8;
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "The Best Sellers",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(fontSize: 35),
          ),
        ),
        Row(
          children: [
            Text(
              "Timeless pieces designed for the modern wardrobe",
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
                "View All",
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
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(_cardPadding),
                    child: ProductCard(cardWidth: _cardWidth),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  shape: CircleBorder(),
                  mini: true,
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
                  child: Icon(Icons.arrow_back),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  mini: true,
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
                  shape: CircleBorder(),
                  child: Icon(Icons.arrow_forward),
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
