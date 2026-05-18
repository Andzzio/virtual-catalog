import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/config/routers/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/config/themes/theme_config.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';

class CatalogFooter extends StatelessWidget {
  const CatalogFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessProvider>().business;
    final customBgColor = ThemeConfig.hexToColor(business?.backgroundColorHex);
    final customThemeColor = ThemeConfig.hexToColor(business?.themeColorHex);

    final bgColor = customBgColor ?? Theme.of(context).scaffoldBackgroundColor;
    final primaryColor = customThemeColor ?? Colors.black;

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(color: primaryColor.withValues(alpha: 0.15)),
          const SizedBox(height: AppPaddings.p32),
          Text(
            business?.name.toUpperCase() ?? 'VIRTUAL CATALOG',
            style: GoogleFonts.getFont(
              FontNames.fontNameH1,
              textStyle: TextStyle(
                color: primaryColor,
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
              textStyle: TextStyle(
                color: primaryColor.withValues(alpha: 0.7),
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
                NavigationHelper.go(context, '/${business.slug}/terms');
              },
              hoverColor: Colors.transparent,
              child: Text(
                "Términos y Condiciones",
                style: GoogleFonts.getFont(
                  FontNames.fontNameP,
                  textStyle: TextStyle(
                    color: primaryColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    decorationColor: primaryColor.withValues(alpha: 0.6),
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
