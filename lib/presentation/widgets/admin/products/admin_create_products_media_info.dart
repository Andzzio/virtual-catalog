import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminCreateProductsMediaInfo extends StatelessWidget {
  const AdminCreateProductsMediaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Media", style: AdminTheme.heading2()),
        const SizedBox(height: 4),
        Text(
          "Sube las imágenes de tus productos.",
          style: AdminTheme.bodySmall(),
        ),
      ],
    );
  }
}
