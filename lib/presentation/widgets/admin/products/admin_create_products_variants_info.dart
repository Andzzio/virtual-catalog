import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminCreateProductsVariantsInfo extends StatelessWidget {
  final Function() onAdd;
  const AdminCreateProductsVariantsInfo({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Variantes", style: AdminTheme.heading2()),
        const SizedBox(height: 4),
        Text(
          "Maneja las variaciones como el color, talla, diseño y precio",
          style: AdminTheme.bodySmall(),
        ),
        SizedBox(height: 20),
        TextButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add, size: 18),
          label: Text("Agregar variante"),
        ),
      ],
    );
  }
}
