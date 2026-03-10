import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyStateWidget({
    super.key,
    this.icon = Icons.storefront_outlined,
    this.title = "Sin productos aún",
    this.subtitle =
        "Los productos aparecerán aquí cuando el negocio los agregue.",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: TextStyle(fontSize: 20, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
