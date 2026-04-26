import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_app_bar.dart';
import 'package:virtual_catalog_app/presentation/widgets/menu_drawer.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessProvider>().business;
    final size = MediaQuery.of(context).size;

    final content = (business != null &&
            business.termsAndConditions != null &&
            business.termsAndConditions!.trim().isNotEmpty)
        ? business.termsAndConditions!
        : "Próximamente";

    return Scaffold(
      appBar: CatalogAppBar(
        isScrolled: true,
        size: size,
        inCatalogScreen: false,
      ),
      drawer: const MenuDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Términos y Condiciones",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH1,
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                MarkdownBody(
                  data: content,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    h1: GoogleFonts.getFont(
                      FontNames.fontNameH1,
                      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    h2: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    h3: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
