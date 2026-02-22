import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/menu_drawer.dart';
import 'package:virtual_catalog_app/presentation/widgets/whatsapp_floating_button.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CatalogAppBar(
        isScrolled: true,
        size: size,
        inCatalogScreen: false,
      ),
      drawer: MenuDrawer(),
      floatingActionButton: WhatsappFloatingButton(),
      endDrawer: CartDrawer(),
    );
  }
}
