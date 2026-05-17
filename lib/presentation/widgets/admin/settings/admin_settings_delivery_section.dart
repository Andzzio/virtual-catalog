import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_type.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class AdminSettingsDeliverySection extends StatelessWidget {
  final List<DeliveryMethod> methods;
  final ValueChanged<List<DeliveryMethod>> onChanged;

  const AdminSettingsDeliverySection({
    super.key,
    required this.methods,
    required this.onChanged,
  });

  void _addMethod() {
    final updated = List<DeliveryMethod>.from(methods)
      ..add(DeliveryMethod(name: "", type: DeliveryType.shipping, price: null));
    onChanged(updated);
  }


  void _removeMethod(int index) {
    final updated = List<DeliveryMethod>.from(methods)..removeAt(index);
    onChanged(updated);
  }

  void _updateMethod(int index, DeliveryMethod method) {
    final updated = List<DeliveryMethod>.from(methods);
    updated[index] = method;
    onChanged(updated);
  }

  void _openMarkdownEditor(BuildContext context, int index, DeliveryMethod method) {
    final controller = TextEditingController(text: method.description ?? "");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Descripción (Markdown)",
            style: GoogleFonts.getFont(FontNames.fontNameH2),
          ),
          content: SizedBox(
            width: 600,
            child: MarkdownField(
              controller: controller,
              emojiConvert: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AdminTheme.accent),
              ),
              onPressed: () {
                final val = controller.text.trim();
                _updateMethod(
                  index,
                  DeliveryMethod(
                    name: method.name,
                    type: method.type,
                    price: method.price,
                    description: val.isEmpty ? null : val,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: AdminTheme.textSecondary),
            const SizedBox(width: 10),
            Text(
              "Métodos de Envío",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addMethod,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                "Agregar",
                style: GoogleFonts.getFont(FontNames.fontNameH2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (methods.isEmpty)
          _buildEmptyHint("No hay métodos de envío configurados.")
        else
          ...List.generate(methods.length, (i) {
            return _buildMethodRow(context, i, methods[i]);
          }),
      ],
    );
  }

  Widget _buildEmptyHint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Text(
        text,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: TextStyle(color: AdminTheme.textMuted, fontSize: 13),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Skill: Use LayoutBuilder for responsive row → column collapse
  Widget _buildMethodRow(BuildContext context, int index, DeliveryMethod method) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AdminTheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 500;

            final nameField = TextFormField(
              initialValue: method.name,
              decoration: _inputDecoration("Nombre"),
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(fontSize: 13),
              ),
              onChanged: (val) => _updateMethod(
                index,
                DeliveryMethod(
                  name: val,
                  type: method.type,
                  price: method.price,
                  description: method.description,
                ),
              ),
            );

            final typeField = DropdownButtonFormField<DeliveryType>(
              initialValue: method.type,
              decoration: _inputDecoration("Tipo"),
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(fontSize: 13, color: AdminTheme.textPrimary),
              ),
              items: DeliveryType.values
                  .map(
                    (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                  )
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                _updateMethod(
                  index,
                  DeliveryMethod(
                    name: method.name,
                    type: val,
                    price: method.price,
                    description: method.description,
                  ),
                );
              },
            );

            final priceField = TextFormField(
              initialValue: method.price != null ? method.price.toString() : "",
              decoration: _inputDecoration("Precio"),
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(fontSize: 13),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) => _updateMethod(
                index,
                DeliveryMethod(
                  name: method.name,
                  type: method.type,
                  price: val.trim().isEmpty ? null : int.tryParse(val.trim()),
                  description: method.description,
                ),
              ),
            );

            final descBtn = OutlinedButton.icon(
              onPressed: () => _openMarkdownEditor(context, index, method),
              icon: const Icon(Icons.edit_note, size: 18),
              label: Text(
                method.description?.isNotEmpty == true
                    ? "Editar Desc."
                    : "Añadir Desc.",
                style: GoogleFonts.getFont(FontNames.fontNameH2,
                    textStyle: const TextStyle(fontSize: 13)),
              ),
              style: AdminTheme.outlinedButton().copyWith(
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
              ),
            );

            final deleteBtn = IconButton(
              onPressed: () => _removeMethod(index),
              icon: const Icon(Icons.close, size: 18),
              style: IconButton.styleFrom(foregroundColor: Colors.redAccent),
              tooltip: "Eliminar método",
            );

            if (isMobile) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: nameField),
                      deleteBtn,
                    ],
                  ),
                  const SizedBox(height: 8),
                  typeField,
                  const SizedBox(height: 8),
                  priceField,
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, child: descBtn),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 3, child: nameField),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: typeField),
                const SizedBox(width: 10),
                Expanded(flex: 1, child: priceField),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: descBtn),
                const SizedBox(width: 8),
                deleteBtn,
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return AdminTheme.inputDecoration(hintText: hint).copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}
