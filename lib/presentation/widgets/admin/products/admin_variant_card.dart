import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminVariantCard extends StatefulWidget {
  final Map<String, dynamic> variant;
  final int index;
  final bool showDelete;
  final Function(int) onRemove;
  final Function(int, String, dynamic) onUpdate;
  const AdminVariantCard({
    super.key,
    required this.variant,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
    this.showDelete = true,
  });

  @override
  State<AdminVariantCard> createState() => _AdminVariantCardState();
}

class _AdminVariantCardState extends State<AdminVariantCard> {
  final TextEditingController _sizeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AdminTheme.breakpointMobile;

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: AdminTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Variant Title + Delete ────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                decoration: BoxDecoration(
                  color: AdminTheme.cardBgElevated,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AdminTheme.radiusMd),
                  ),
                  border: Border(bottom: BorderSide(color: AdminTheme.border)),
                ),
                child: Row(
                  children: [
                    Text(
                      "Variante #${widget.index + 1}",
                      style: AdminTheme.body().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.accentLight,
                      ),
                    ),
                    const Spacer(),
                    if (widget.showDelete)
                      IconButton(
                        onPressed: () => widget.onRemove(widget.index),
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AdminTheme.danger,
                        tooltip: "Eliminar variante",
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ── Row 1: Name, SKU ────────────────────────
                    _buildResponsiveRow(
                      isMobile: isMobile,
                      children: [
                        _field(
                          "Nombre de Variante",
                          TextFormField(
                            initialValue: widget.variant["name"],
                            decoration: AdminTheme.inputDecoration(
                              hintText: "ej. Rojo / XL...",
                            ),
                            onChanged: (v) =>
                                widget.onUpdate(widget.index, "name", v),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Requerido" : null,
                          ),
                          flex: 3,
                        ),
                        _field(
                          "SKU (Opcional)",
                          TextFormField(
                            initialValue: widget.variant["sku"],
                            decoration: AdminTheme.inputDecoration(
                              hintText: "ej. VC-RED-XL",
                            ),
                            onChanged: (v) =>
                                widget.onUpdate(widget.index, "sku", v),
                          ),
                          flex: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Row 2: Price, Discount, Color ───────────
                    _buildResponsiveRow(
                      isMobile: isMobile,
                      children: [
                        _field(
                          "Precio Original",
                          TextFormField(
                            initialValue: widget.variant["origPrice"],
                            decoration: AdminTheme.inputDecoration(
                              hintText: "0.00",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                widget.onUpdate(widget.index, "origPrice", v),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Requerido" : null,
                          ),
                        ),
                        _field(
                          "Precio Oferta",
                          TextFormField(
                            initialValue: widget.variant["discountPrice"],
                            decoration: AdminTheme.inputDecoration(
                              hintText: "Opcional",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => widget.onUpdate(
                              widget.index,
                              "discountPrice",
                              v,
                            ),
                          ),
                        ),
                        _field("Color", _buildColorButton(), flex: 0),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Row 3: Stock ────────────────────────────
                    _buildResponsiveRow(
                      isMobile: isMobile,
                      children: [
                        _field(
                          "Stock",
                          TextFormField(
                            initialValue: widget.variant["stock"],
                            decoration: AdminTheme.inputDecoration(
                              hintText: "100",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                widget.onUpdate(widget.index, "stock", v),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Requerido" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Section: Sizes ──────────────────────────
                    _field(
                      "Tallas disponibles",
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _sizeCtrl,
                            decoration: AdminTheme.inputDecoration(
                              hintText: "Escribe una talla y presiona Enter",
                            ),
                            onFieldSubmitted: _onSizeSubmitted,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              widget.variant["sizes"].length,
                              (idx) {
                                final size = widget.variant["sizes"][idx];
                                return Chip(
                                  label: Text(size),
                                  labelStyle: AdminTheme.bodySmall().copyWith(
                                    color: AdminTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  backgroundColor: AdminTheme.cardBgElevated,
                                  side: BorderSide(color: AdminTheme.border),
                                  onDeleted: () {
                                    List<String> current = List<String>.from(
                                      widget.variant["sizes"],
                                    );
                                    current.removeAt(idx);
                                    widget.onUpdate(
                                      widget.index,
                                      "sizes",
                                      current,
                                    );
                                  },
                                  deleteIconColor: AdminTheme.danger,
                                  deleteIcon: const Icon(Icons.close, size: 14),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveRow({
    required bool isMobile,
    required List<Widget> children,
  }) {
    if (isMobile) {
      return Column(
        children: children
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
            )
            .toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map(
            (c) => Expanded(
              flex: (c is _FieldWidget) ? c.flex : 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: c,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _field(String label, Widget child, {int flex = 1}) {
    return _FieldWidget(
      label: label,
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AdminTheme.bodySmall().copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildColorButton() {
    final color = widget.variant["colorInt"] != null
        ? Color(widget.variant["colorInt"])
        : AdminTheme.accent;

    return InkWell(
      onTap: _showColorPicker,
      borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
      child: Container(
        height: 48,
        width: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
          border: Border.all(color: AdminTheme.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.colorize, color: Colors.white, size: 20),
      ),
    );
  }

  void _onSizeSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      final List<String> current = List<String>.from(
        widget.variant["sizes"] ?? [],
      );
      if (!current.contains(value.trim())) {
        current.add(value.trim());
        widget.onUpdate(widget.index, "sizes", current);
      }
      _sizeCtrl.clear();
    }
  }

  void _showColorPicker() {
    Color pickerColor = widget.variant["colorInt"] != null
        ? Color(widget.variant["colorInt"])
        : AdminTheme.accent;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Color de variante", style: AdminTheme.heading2()),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onUpdate(widget.index, "colorInt", pickerColor.toARGB32());
              context.pop();
            },
            style: AdminTheme.primaryButton(),
            child: const Text("Aplicar"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sizeCtrl.dispose();
    super.dispose();
  }
}

class _FieldWidget extends StatelessWidget {
  final String label;
  final Widget child;
  final int flex;
  const _FieldWidget({required this.label, required this.child, this.flex = 1});

  @override
  Widget build(BuildContext context) => child;
}
