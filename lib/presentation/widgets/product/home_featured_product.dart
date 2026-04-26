import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_image_section.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/product_info_section.dart';

class HomeFeaturedProduct extends StatelessWidget {
  final HomeBlock block;
  final Product product;

  const HomeFeaturedProduct({
    super.key,
    required this.block,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

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
          const SizedBox(height: 8),
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
      ],
    );
  }
}
