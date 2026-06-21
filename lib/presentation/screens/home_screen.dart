import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/banner/banner_image.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_footer.dart';
import 'package:virtual_catalog_app/presentation/widgets/menu_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/home_block_renderer.dart';
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
    final BusinessProvider businessProvider = context.watch<BusinessProvider>();
    final size = MediaQuery.of(context).size;
    final business = businessProvider.business;
    final blocks = business?.homeBlocks ?? [];

    if (business != null && !business.isActive) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_rounded, size: 72, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Tienda no disponible",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Esta tienda se encuentra temporalmente inactiva o fuera de servicio.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                  ...blocks.map((block) {
                    final blockProducts = provider.getProductsForBlock(block);
                    return Column(
                      children: [
                        HomeBlockRenderer(
                          block: block,
                          products: blockProducts,
                        ),
                        SizedBox(height: 50),
                      ],
                    );
                  }),
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
