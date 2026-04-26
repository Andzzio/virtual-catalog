import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_card.dart';

class HomeGridProducts extends StatefulWidget {
  final HomeBlock block;
  final List<Product> products;
  const HomeGridProducts({
    super.key,
    required this.block,
    required this.products,
  });

  @override
  State<HomeGridProducts> createState() => _HomeGridProductsState();
}

class _HomeGridProductsState extends State<HomeGridProducts> {
  @override
  Widget build(BuildContext context) {
    final activeProducts = widget.products;
    if (activeProducts.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.block.title,
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 800 ? 24 : 35,
            ),
          ),
        ),
        if (widget.block.subtitle != null)
          Text(
            widget.block.subtitle!,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: 16, color: Color(0xFF82868B)),
            ),
          ),
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 1500),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GridView.builder(
                  itemCount: activeProducts.length,
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
                    final Product product = activeProducts[index];
                    return ProductCard(
                      cardWidth: double.infinity,
                      isPageView: true,
                      product: product,
                    );
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
}
