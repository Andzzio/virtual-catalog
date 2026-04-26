import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/app_dialog.dart';

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
    return AppBar(
      backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
      toolbarHeight: 65,
      leadingWidth: isMobile ? 56 : size.width * 0.1,
      centerTitle: true,
      leading: isMobile
          ? IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.menu,
                color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
              ),
            )
          : Center(
              child: _buildLogo(
                isMobile: isMobile,
                showDesktopLogo: showDesktopLogo,
                showMobileLogo: showMobileLogo,
                businessName: businessName,
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
                    context.go("/$slug");
                  },
                  child: Text(
                    "Inicio",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: TextStyle(
                        color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
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
                    context.go("/$slug/catalog");
                  },
                  child: Text(
                    "Catálogo",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: TextStyle(
                        color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
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
              Icons.search,
              color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
            ),
          ),
        SizedBox(width: 20),
        IconButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          icon: Badge(
            isLabelVisible: cartProvider.itemCount > 0,
            label: Text("${cartProvider.itemCount}"),
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.shopping_cart_rounded,
              color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
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
                  color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
                  fontWeight: FontWeight.bold,
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
                  color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              textAlign: TextAlign.center,
            )
          : Text("");
    }
  }
}
