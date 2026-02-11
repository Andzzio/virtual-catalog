import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/widgets/product_card.dart';

class HomeGridProducts extends StatefulWidget {
  const HomeGridProducts({super.key});

  @override
  State<HomeGridProducts> createState() => _HomeGridProductsState();
}

class _HomeGridProductsState extends State<HomeGridProducts> {
  final double _cardWidth = 300;
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nuevos ingresos",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(fontSize: 35),
          ),
        ),
        Text(
          "Descubre las últimas tendencias y novedades que acaban de llegar",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(fontSize: 16, color: Color(0xFF82868B)),
          ),
        ),
        SizedBox(height: 40),
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 1500),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GridView.builder(
                  itemCount: 4,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: constraints.maxWidth > 700
                      ? SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.6,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                        )
                      : SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                        ),
                  itemBuilder: (context, index) {
                    return ProductCard(cardWidth: _cardWidth);
                  },
                );
              },
            ),
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
