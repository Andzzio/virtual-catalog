import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_view.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Drawer(
      width: (size.width * 0.3).clamp(350, 500),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
      ),
      child: CartView(),
    );
  }
}
