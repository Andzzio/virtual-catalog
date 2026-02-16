import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/banner/banner_image.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/home_grid_products.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/home_list_products.dart';
import 'package:virtual_catalog_app/presentation/widgets/whatsapp_floating_button.dart';

class HomeScreen extends StatefulWidget {
  final String? businessSlug;
  const HomeScreen({super.key, this.businessSlug});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;
  @override
  Widget build(BuildContext context) {
    final ProductProvider provider = context.watch<ProductProvider>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CatalogAppBar(isScrolled: _isScrolled, size: size),
      endDrawer: CartDrawer(),
      floatingActionButton: WhatsappFloatingButton(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            BannerImage(size: size),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                  HomeListProducts(provider: provider),
                  SizedBox(height: 50),
                  HomeGridProducts(provider: provider),
                  SizedBox(height: 50),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: Center(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "© 2026 Virtual Catalog",
                      style: GoogleFonts.getFont(FontNames.fontNameP),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 1 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 1 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
