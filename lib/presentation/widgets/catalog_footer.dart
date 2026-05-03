import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';

class CatalogFooter extends StatelessWidget {
  const CatalogFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessProvider>().business;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(color: AppColors.border.withValues(alpha: 0.5)),
          const SizedBox(height: AppPaddings.p32),
          Text(
            business?.name.toUpperCase() ?? 'VIRTUAL CATALOG',
            style: GoogleFonts.getFont(
              FontNames.fontNameH1,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppPaddings.p16),
          Text(
            "© ${DateTime.now().year} Todos los derechos reservados.",
            style: GoogleFonts.getFont(
              FontNames.fontNameP,
              textStyle: const TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          if (business != null &&
              business.termsAndConditions != null &&
              business.termsAndConditions!.trim().isNotEmpty) ...[
            const SizedBox(height: AppPaddings.p24),
            InkWell(
              onTap: () {
                context.go('/${business.slug}/terms');
              },
              hoverColor: Colors.transparent,
              child: Text(
                "Términos y Condiciones",
                style: GoogleFonts.getFont(
                  FontNames.fontNameP,
                  textStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textMuted,
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
