import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

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
      id:
          widget.initialBlock?.id ??
          "block_${DateTime.now().millisecondsSinceEpoch}",
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
      specificProductId: _sortCriteria == BlockSortCriteria.manual
          ? _specificProductId
          : null,
    );

    widget.onSave(newBlock);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialBlock != null;

    return Dialog(
      backgroundColor: AdminTheme.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header ──────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AdminTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing
                              ? "Editar Sección"
                              : "Nueva Sección del Home",
                          style: AdminTheme.heading2(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Las secciones muestran grupos de productos en tu tienda.",
                          style: AdminTheme.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // ─── Body ────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildLabel("¿Cómo se llama esta sección?"),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: AdminTheme.inputDecoration(
                          hintText: "Ej: Lo más vendido",
                        ),
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? "Requerido" : null,
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      _buildLabel("Subtítulo (Opcional)"),
                      TextFormField(
                        controller: _subtitleCtrl,
                        decoration: AdminTheme.inputDecoration(
                          hintText: "Ej: Descubre las últimas tendencias",
                        ),
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                      const SizedBox(height: 20),

                      // ─── Layout selection with visual cards ───
                      _buildLabel("¿Cómo quieres que se vean los productos?"),
                      const SizedBox(height: 4),
                      _buildLayoutSelector(),
                      const SizedBox(height: 20),

                      // Sort criteria
                      _buildLabel("¿Qué productos mostrar primero?"),
                      DropdownButtonFormField<BlockSortCriteria>(
                        isExpanded: true,
                        initialValue: _sortCriteria,
                        dropdownColor: AdminTheme.cardBgElevated,
                        decoration: AdminTheme.inputDecoration(hintText: ""),
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: BlockSortCriteria.newest,
                            child: Text("🆕 Los más nuevos"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.bestSelling,
                            child: Text("🔥 Los más vendidos"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.biggestDiscount,
                            child: Text("💰 Mayor descuento"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.premiumFirst,
                            child: Text("💎 Precio alto primero"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.affordableFirst,
                            child: Text("🏷️ Precio bajo primero"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.recentlyUpdated,
                            child: Text("🔄 Actualizados recientemente"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.alphabetical,
                            child: Text("🔤 Orden alfabético"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.manual,
                            child: Text("👆 Elegir un producto específico"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _sortCriteria = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Manual product picker
                      if (_sortCriteria == BlockSortCriteria.manual) ...[
                        _buildLabel("Selecciona el Producto"),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _specificProductId,
                          dropdownColor: AdminTheme.cardBgElevated,
                          decoration: AdminTheme.inputDecoration(
                            hintText: "Seleccionar...",
                          ),
                          items: context
                              .read<ProductProvider>()
                              .products
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _specificProductId = val),
                          validator: (v) =>
                              v == null ? "Selecciona un producto" : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Items limit (only for list/grid)
                      if (_layout != BlockLayout.featured &&
                          _layout != BlockLayout.mosaic) ...[
                        _buildLabel("¿Cuántos productos mostrar?"),
                        TextFormField(
                          controller: _itemsLimitCtrl,
                          keyboardType: TextInputType.number,
                          decoration: AdminTheme.inputDecoration(
                            hintText: "Ej: 10",
                          ),
                          style: GoogleFonts.getFont(FontNames.fontNameH2),
                          validator: (v) => int.tryParse(v ?? "") == null
                              ? "Número inválido"
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Show button toggle
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AdminTheme.surface,
                          borderRadius: BorderRadius.circular(
                            AdminTheme.radiusMd,
                          ),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                "Mostrar botón 'Ver todos'",
                                style: AdminTheme.body(),
                              ),
                              subtitle: Text(
                                "Añade un enlace para ver todos los productos de esta sección.",
                                style: AdminTheme.caption(),
                              ),
                              value: _showButton,
                              onChanged: (val) =>
                                  setState(() => _showButton = val),
                            ),
                            if (_showButton) ...[
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _buttonTextCtrl,
                                decoration: AdminTheme.inputDecoration(
                                  hintText: "Texto del botón",
                                ),
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Footer ─────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AdminTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: AdminTheme.outlinedButton(),
                      child: Text(
                        "Cancelar",
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: AdminTheme.primaryButton(),
                      child: Text(
                        isEditing ? "Guardar" : "Crear Sección",
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Visual layout selector — clear for gamarra users
  Widget _buildLayoutSelector() {
    final options = [
      _LayoutOption(
        layout: BlockLayout.list,
        icon: Icons.view_list_rounded,
        name: "Carrusel",
        desc: "Se desliza de lado a lado",
      ),
      _LayoutOption(
        layout: BlockLayout.grid,
        icon: Icons.grid_view,
        name: "Grilla",
        desc: "Productos en cuadrícula",
      ),
      _LayoutOption(
        layout: BlockLayout.mosaic,
        icon: Icons.view_quilt_outlined,
        name: "Mosaico",
        desc: "1 grande + 2 pequeños",
      ),
      _LayoutOption(
        layout: BlockLayout.featured,
        icon: Icons.star_outline,
        name: "Estrella",
        desc: "Un solo producto destacado",
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = _layout == opt.layout;
        return GestureDetector(
          onTap: () {
            setState(() {
              _layout = opt.layout;
              if (_layout == BlockLayout.featured) {
                _sortCriteria = BlockSortCriteria.manual;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AdminTheme.accent.withValues(alpha: 0.06)
                  : AdminTheme.cardBg,
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              border: Border.all(
                color: isSelected ? AdminTheme.accent : AdminTheme.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  opt.icon,
                  size: 28,
                  color: isSelected
                      ? AdminTheme.accent
                      : AdminTheme.textSecondary,
                ),
                const SizedBox(height: 6),
                Text(
                  opt.name,
                  style: AdminTheme.body().copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  opt.desc,
                  style: AdminTheme.caption().copyWith(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AdminTheme.body().copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _LayoutOption {
  final BlockLayout layout;
  final IconData icon;
  final String name;
  final String desc;

  const _LayoutOption({
    required this.layout,
    required this.icon,
    required this.name,
    required this.desc,
  });
}
