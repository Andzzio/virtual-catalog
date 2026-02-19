import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog/catalog_grid_view.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog/filter_catalog_view.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/whatsapp_floating_button.dart';

class CatalogScreen extends StatefulWidget {
  final String? businessSlug;
  const CatalogScreen({super.key, this.businessSlug});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: CatalogAppBar(
        isScrolled: true,
        size: size,
        inCatalogScreen: true,
      ),
      floatingActionButton: WhatsappFloatingButton(),
      endDrawer: CartDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (constraints.maxWidth > 700)
                Expanded(flex: 3, child: FilterCatalogView()),
              Expanded(flex: 10, child: CatalogGridView()),
            ],
          );
        },
      ),
    );
  }
}
