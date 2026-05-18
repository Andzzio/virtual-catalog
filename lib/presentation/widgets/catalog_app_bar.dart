import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virtual_catalog_app/config/routers/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/app_dialog.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';

class CatalogAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool inCatalogScreen;
  const CatalogAppBar({
    super.key,
    required bool isScrolled,
    required this.size,
    required this.inCatalogScreen,
  }) : _isScrolled = isScrolled;

  final bool _isScrolled;
  final Size size;

  @override
  Size get preferredSize => Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final business = context.watch<BusinessProvider>().business;
    final showDesktopLogo = business?.showDesktopLogo ?? false;
    final showMobileLogo = business?.showMobileLogo ?? false;
    final businessName = business?.name ?? "";
    final CartProvider cartProvider = context.watch<CartProvider>();
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: _isScrolled ? AppColors.surface.withValues(alpha: 0.85) : Colors.transparent,
      elevation: 0,
      flexibleSpace: _isScrolled
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.transparent),
              ),
            )
          : null,
      toolbarHeight: 65,
      leadingWidth: isMobile ? 56 : 250,
      centerTitle: true,
      leading: isMobile
          ? IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.menu_rounded,
                color: _isScrolled ? AppColors.textDark : const Color(0xFFB3B8C1),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: AppPaddings.p32),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildLogo(
                  isMobile: isMobile,
                  showDesktopLogo: showDesktopLogo,
                  showMobileLogo: showMobileLogo,
                  businessName: businessName,
                ),
              ),
            ),
      title: isMobile
          ? Center(
              child: _buildLogo(
                isMobile: isMobile,
                showDesktopLogo: showDesktopLogo,
                showMobileLogo: showMobileLogo,
                businessName: businessName,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    final slug = GoRouterState.of(
                      context,
                    ).pathParameters["businessSlug"];
                    NavigationHelper.go(context, "/$slug");
                  },
                  child: Text(
                    "Inicio",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _isScrolled ? AppColors.textDark : const Color(0xFFB3B8C1),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    final String slug = GoRouterState.of(
                      context,
                    ).pathParameters["businessSlug"]!;
                    NavigationHelper.go(context, "/$slug/catalog");
                  },
                  child: Text(
                    "Catálogo",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _isScrolled ? AppColors.textDark : const Color(0xFFB3B8C1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      actions: [
        if (!inCatalogScreen)
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AppDialog();
                },
              );
            },
            icon: Icon(
              Icons.search_rounded,
              color: _isScrolled ? AppColors.textDark : const Color(0xFFB3B8C1),
            ),
          ),
        SizedBox(width: 20),
        IconButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          icon: Badge(
            isLabelVisible: cartProvider.itemCount > 0,
            label: Text("${cartProvider.itemCount}", style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: theme.primaryColor, // <-- Color dinámico inyectado de la base de datos
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 26,
              color: _isScrolled ? AppColors.textDark : const Color(0xFFB3B8C1),
            ),
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  Widget _buildLogo({
    bool isMobile = false,
    bool showDesktopLogo = true,
    bool showMobileLogo = true,
    String businessName = "",
  }) {
    if (isMobile) {
      return showMobileLogo
          ? Text(
              businessName,
              style: GoogleFonts.getFont(
                FontNames.fontNameH1,
                textStyle: TextStyle(
                  color: _isScrolled ? AppColors.textDark : const Color(0xFFB3B8C1),
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontSize: 20,
                ),
              ),
              textAlign: TextAlign.center,
            )
          : Text("");
    } else {
      return showDesktopLogo
          ? Text(
              businessName,
              style: GoogleFonts.getFont(
                FontNames.fontNameH1,
                textStyle: TextStyle(
                  color: _isScrolled ? AppColors.textDark : const Color(0xFFB3B8C1),
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontSize: 24,
                ),
              ),
              textAlign: TextAlign.center,
            )
          : Text("");
    }
  }
}
