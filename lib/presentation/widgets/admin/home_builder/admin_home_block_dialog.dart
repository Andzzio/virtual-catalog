import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';

class AdminHomeBlockDialog extends StatefulWidget {
  final HomeBlock? initialBlock;
  final ValueChanged<HomeBlock> onSave;

  const AdminHomeBlockDialog({
    super.key,
    this.initialBlock,
    required this.onSave,
  });

  @override
  State<AdminHomeBlockDialog> createState() => _AdminHomeBlockDialogState();
}

class _AdminHomeBlockDialogState extends State<AdminHomeBlockDialog> {
  final _formKey = GlobalKey<FormState>();

  late BlockLayout _layout;
  late BlockSortCriteria _sortCriteria;
  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late bool _showButton;
  late TextEditingController _buttonTextCtrl;
  late TextEditingController _itemsLimitCtrl;
  String? _specificProductId;

  @override
  void initState() {
    super.initState();
    final block = widget.initialBlock;
    _layout = block?.layout ?? BlockLayout.list;
    _sortCriteria = block?.sortCriteria ?? BlockSortCriteria.newest;
    _titleCtrl = TextEditingController(text: block?.title ?? "");
    _subtitleCtrl = TextEditingController(text: block?.subtitle ?? "");
    _showButton = block?.showButton ?? false;
    _buttonTextCtrl = TextEditingController(
      text: block?.buttonText ?? "Ver todos",
    );
    _itemsLimitCtrl = TextEditingController(
      text: (block?.itemsLimit ?? 10).toString(),
    );
    _specificProductId = block?.specificProductId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _buttonTextCtrl.dispose();
    _itemsLimitCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final limit = int.tryParse(_itemsLimitCtrl.text) ?? 10;

    final newBlock = HomeBlock(
      id: widget.initialBlock?.id ?? "block_${DateTime.now().millisecondsSinceEpoch}",
      layout: _layout,
      title: _titleCtrl.text.trim(),
      subtitle: _subtitleCtrl.text.trim().isEmpty
          ? null
          : _subtitleCtrl.text.trim(),
      showButton: _showButton,
      buttonText: _buttonTextCtrl.text.trim().isEmpty
          ? null
          : _buttonTextCtrl.text.trim(),
      sortCriteria: _sortCriteria,
      itemsLimit: _layout == BlockLayout.featured
          ? 1
          : (_layout == BlockLayout.mosaic ? 3 : limit),
      specificProductId: _sortCriteria == BlockSortCriteria.manual ? _specificProductId : null,
    );

    widget.onSave(newBlock);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialBlock == null ? "Nuevo Bloque" : "Editar Bloque",
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabel("Título del Bloque"),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _inputDeco("Ej. Nuestros productos más vendidos"),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Requerido" : null,
                ),
                const SizedBox(height: 16),

                _buildLabel("Subtítulo (Opcional)"),
                TextFormField(
                  controller: _subtitleCtrl,
                  decoration: _inputDeco(
                    "Ej. Descubre las últimas tendencias...",
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Layout (Apariencia)"),
                          DropdownButtonFormField<BlockLayout>(
                            isExpanded: true,
                            initialValue: _layout,
                            decoration: _inputDeco(""),
                            items: const [
                              DropdownMenuItem(
                                value: BlockLayout.list,
                                child: Text("Carrusel Horizontal"),
                              ),
                              DropdownMenuItem(
                                value: BlockLayout.grid,
                                child: Text("Grilla Mosaico"),
                              ),
                              DropdownMenuItem(
                                value: BlockLayout.mosaic,
                                child: Text("Mosaico Destacado (1 Grande, 2 Pequeños)"),
                              ),
                              DropdownMenuItem(
                                value: BlockLayout.featured,
                                child: Text("Producto Estrella (Vista Completa)"),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _layout = val;
                                  if (_layout == BlockLayout.featured) {
                                    _sortCriteria = BlockSortCriteria.manual;
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_layout != BlockLayout.featured && _layout != BlockLayout.mosaic) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Límite de Productos"),
                            TextFormField(
                              controller: _itemsLimitCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _inputDeco("Ej. 10"),
                              validator: (v) => int.tryParse(v ?? "") == null
                                  ? "Número inválido"
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel("Inteligencia (Criterio de Ordenamiento)"),
                DropdownButtonFormField<BlockSortCriteria>(
                  isExpanded: true,
                  initialValue: _sortCriteria,
                  decoration: _inputDeco(""),
                  items: const [
                    DropdownMenuItem(
                      value: BlockSortCriteria.newest,
                      child: Text("Nuevos Ingresos (Recientes)"),
                    ),
                    DropdownMenuItem(
                      value: BlockSortCriteria.biggestDiscount,
                      child: Text("Liquidación (Mayores Descuentos primero)"),
                    ),
                    DropdownMenuItem(
                      value: BlockSortCriteria.bestSelling,
                      child: Text("Más Vendidos (Ventas)"),
                    ),
                    DropdownMenuItem(
                      value: BlockSortCriteria.premiumFirst,
                      child: Text("Colección Premium (Mayor precio primero)"),
                    ),
                    DropdownMenuItem(
                      value: BlockSortCriteria.affordableFirst,
                      child: Text("Ofertas Rápidas (Menor precio primero)"),
                    ),
                    DropdownMenuItem(
                      value: BlockSortCriteria.recentlyUpdated,
                      child: Text("Recién Actualizados"),
                    ),
                    DropdownMenuItem(
                      value: BlockSortCriteria.alphabetical,
                      child: Text("Alfabético (A-Z)"),
                    ),
                    DropdownMenuItem(
                      value: BlockSortCriteria.manual,
                      child: Text("Selección Manual (Elegir un producto)"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _sortCriteria = val);
                  },
                ),
                const SizedBox(height: 16),

                if (_sortCriteria == BlockSortCriteria.manual) ...[
                  _buildLabel("Selecciona el Producto"),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _specificProductId,
                    decoration: _inputDeco("Seleccionar..."),
                    items: context.read<ProductProvider>().products.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _specificProductId = val);
                    },
                    validator: (v) => v == null ? "Selecciona un producto" : null,
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    Switch(
                      value: _showButton,
                      onChanged: (val) => setState(() => _showButton = val),
                    ),
                    const SizedBox(width: 8),
                    _buildLabel("Mostrar botón de acción (Ej. Ver todos)"),
                  ],
                ),
                if (_showButton) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _buttonTextCtrl,
                    decoration: _inputDeco("Texto del botón"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancelar", style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text("Guardar Bloque"),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }
}
