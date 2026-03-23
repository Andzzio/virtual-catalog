import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_type.dart';

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
      ..add(DeliveryMethod(name: "", type: DeliveryType.shipping, price: 0));
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: Colors.grey[700]),
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
            return _buildMethodRow(i, methods[i]);
          }),
      ],
    );
  }

  Widget _buildEmptyHint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMethodRow(int index, DeliveryMethod method) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E2E2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
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
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<DeliveryType>(
                initialValue: method.type,
                decoration: _inputDecoration("Tipo"),
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(fontSize: 13, color: Colors.black),
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
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: method.price > 0 ? method.price.toString() : "",
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
                    price: int.tryParse(val) ?? 0,
                    description: method.description,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: method.description ?? "",
                decoration: _inputDecoration("Descripción (opcional)"),
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(fontSize: 13),
                ),
                onChanged: (val) => _updateMethod(
                  index,
                  DeliveryMethod(
                    name: method.name,
                    type: method.type,
                    price: method.price,
                    description: val.isEmpty ? null : val,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _removeMethod(index),
              icon: const Icon(Icons.close, size: 18),
              style: IconButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.getFont(
        FontNames.fontNameH2,
        textStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }
}
