import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';

class CatalogAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CatalogAppBar({super.key, required bool isScrolled, required this.size})
    : _isScrolled = isScrolled;

  final bool _isScrolled;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = context.watch<CartProvider>();
    return AppBar(
      backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
      toolbarHeight: 65,
      leadingWidth: size.width * 0.1,
      centerTitle: true,
      leading: Center(
        child: Text(
          "VIRTUAL CATALOG",
          style: GoogleFonts.getFont(
            FontNames.fontNameH1,
            textStyle: TextStyle(
              color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              context.go("/");
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
            onPressed: () {},
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
        SizedBox(
          width: size.width * 0.15,
          height: 40,
          child: TextField(
            style: TextStyle(
              color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, size: 20),
              prefixIconColor: Color(0xFFB3B8C1),

              hintText: "Buscar...",
              hintStyle: GoogleFonts.getFont(
                FontNames.fontNameP,
                textStyle: TextStyle(color: Color(0xFFB3B8C1)),
              ),

              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB3B8C1)),
              ),
            ),
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
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.person_2_rounded,
            color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(65);
}
