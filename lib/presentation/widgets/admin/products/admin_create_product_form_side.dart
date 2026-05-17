import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminCreateProductFormSide extends StatelessWidget {
  final Function(String) onNameChanged;
  final Function(String) onCategoryChanged;
  final Function(String) onSkuChanged;
  final Function(String) onDescriptionChanged;
  final String? initialName;
  final String? initialCategory;
  final String? initialSku;
  final String? initialDescription;

  const AdminCreateProductFormSide({
    super.key,
    required this.onNameChanged,
    required this.onCategoryChanged,
    required this.onSkuChanged,
    required this.onDescriptionChanged,
    this.initialName,
    this.initialCategory,
    this.initialSku,
    this.initialDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nombre del Producto",
            style: AdminTheme.body().copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: initialName,
            decoration: AdminTheme.inputDecoration(
              hintText: "ej. Camiseta Amarilla...",
            ),
            onChanged: (value) => onNameChanged(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "El nombre es obligatorio";
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          // Skill: LayoutBuilder for responsive row
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile =
                  constraints.maxWidth < AdminTheme.breakpointMobile;

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryField(),
                    SizedBox(height: 20),
                    _buildSkuField(),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildCategoryField()),
                  SizedBox(width: 20),
                  Expanded(child: _buildSkuField()),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          Text(
            "Descripción",
            style: AdminTheme.body().copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: initialDescription,
            decoration: AdminTheme.inputDecoration(
              hintText:
                  "Describe las características y materiales del producto...",
            ),
            maxLines: 5,
            onChanged: (value) => onDescriptionChanged(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "La descripción es obligatoria";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Categoría",
          style: AdminTheme.body().copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextFormField(
          initialValue: initialCategory,
          decoration: AdminTheme.inputDecoration(hintText: "ej. Pantalones..."),
          onChanged: (value) => onCategoryChanged(value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "La categoría es obligatoria";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSkuField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SKU (Opcional)",
          style: AdminTheme.body().copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextFormField(
          initialValue: initialSku,
          decoration: AdminTheme.inputDecoration(hintText: "VC-001..."),
          onChanged: (value) => onSkuChanged(value),
        ),
      ],
    );
  }
}
