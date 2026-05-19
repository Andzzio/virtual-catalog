import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virtual_catalog_app/config/routers/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPaddings.p24, vertical: AppPaddings.p32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "NAVEGACIÓN",
            style: GoogleFonts.getFont(
              FontNames.fontNameP,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppPaddings.p16),
          _buildMenuTile(
            context: context,
            icon: Icons.home_rounded,
            title: "Inicio",
            onTap: () {
              final slug = NavigationHelper.getSlug(context);
              context.pop();
              NavigationHelper.go(context, "/$slug");
            },
          ),
          const SizedBox(height: AppPaddings.p8),
          _buildMenuTile(
            context: context,
            icon: Icons.storefront_rounded,
            title: "Catálogo",
            onTap: () {
              final slug = NavigationHelper.getSlug(context);
              context.pop();
              NavigationHelper.go(context, "/$slug/catalog");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textDark, size: 26),
      title: Text(
        title,
        style: GoogleFonts.getFont(
          FontNames.fontNameP,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppPaddings.p16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorders.radiusButton),
      ),
      hoverColor: AppColors.border.withValues(alpha: 0.3),
      onTap: onTap,
    );
  }
}
