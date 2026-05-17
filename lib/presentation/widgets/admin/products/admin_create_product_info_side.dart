import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminCreateProductInfoSide extends StatelessWidget {
  const AdminCreateProductInfoSide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Información Básica", style: AdminTheme.heading2()),
        const SizedBox(height: 4),
        Text(
          "Esta información será mostrada en los detalles de cada producto.",
          style: AdminTheme.bodySmall(),
        ),
      ],
    );
  }
}
