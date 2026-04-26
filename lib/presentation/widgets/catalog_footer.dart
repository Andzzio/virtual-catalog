import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';

class CatalogFooter extends StatelessWidget {
  const CatalogFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessProvider>().business;

    return Container(
      width: double.infinity,
      color: const Color(0xFF1E1E1E), // Fondo gris oscuro
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "© ${DateTime.now().year} ${business?.name ?? 'Virtual Catalog'}. Todos los derechos reservados.",
            style: GoogleFonts.getFont(
              FontNames.fontNameP,
              textStyle: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            textAlign: TextAlign.center,
          ),
          if (business != null &&
              business.termsAndConditions != null &&
              business.termsAndConditions!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                context.go('/${business.slug}/terms');
              },
              child: Text(
                "Términos y Condiciones",
                style: GoogleFonts.getFont(
                  FontNames.fontNameP,
                  textStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
