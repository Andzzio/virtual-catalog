import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/banner/banner_image.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_footer.dart';
import 'package:virtual_catalog_app/presentation/widgets/menu_drawer.dart';
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
    final isMobile = MediaQuery.of(context).size.width < 800;
    final ProductProvider provider = context.watch<ProductProvider>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: MenuDrawer(),
      appBar: CatalogAppBar(
        isScrolled: _isScrolled,
        size: size,
        inCatalogScreen: false,
      ),
      endDrawer: CartDrawer(),
      floatingActionButton: WhatsappFloatingButton(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            BannerImage(size: size),
            SizedBox(height: 100),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 50),
              child: Column(
                children: [
                  HomeListProducts(provider: provider),
                  SizedBox(height: 50),
                  HomeGridProducts(provider: provider),
                  SizedBox(height: 50),
                ],
              ),
            ),
            const CatalogFooter(),
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
