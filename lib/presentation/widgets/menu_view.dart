import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Accesos",
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Inicio"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () {
              final slug = GoRouterState.of(
                context,
              ).pathParameters["businessSlug"];
              context.pop();
              context.go("/$slug");
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_basket),
            title: Text("Catálogo"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () {
              final slug = GoRouterState.of(
                context,
              ).pathParameters["businessSlug"];
              context.pop();
              context.go("/$slug/catalog");
            },
          ),
        ],
      ),
    );
  }
}
