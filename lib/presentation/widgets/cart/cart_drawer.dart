import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/widgets/cart/cart_view.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Drawer(
      width: size.width < 600
          ? size.width * 0.85
          : (size.width * 0.3).clamp(350, 500).toDouble(),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(AppBorders.radiusCard)),
      ),
      child: CartView(),
    );
  }
}
