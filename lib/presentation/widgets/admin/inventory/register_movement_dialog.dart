import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/stock_movement_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class RegisterMovementDialog extends StatefulWidget {
  final String businessSlug;
  const RegisterMovementDialog({super.key, required this.businessSlug});

  @override
  State<RegisterMovementDialog> createState() => _RegisterMovementDialogState();
}

class _RegisterMovementDialogState extends State<RegisterMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'ingreso';
  String? _selectedProductId;
  String? _selectedVariantName;
  int _quantity = 1;
  String _reason = '';
  String _reference = '';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;

    Product? selectedProduct;
    if (_selectedProductId != null) {
      try {
        selectedProduct = products.firstWhere((p) => p.id == _selectedProductId);
      } catch (_) {
        selectedProduct = null;
      }
    }

    ProductVariant? selectedVariant;
    if (selectedProduct != null && _selectedVariantName != null) {
      try {
        selectedVariant = selectedProduct.variants.firstWhere((v) => v.name == _selectedVariantName);
      } catch (_) {
        selectedVariant = null;
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Registrar Movimiento",
                  style: AdminTheme.heading2(),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _type,
                  dropdownColor: AdminTheme.cardBgElevated,
                  decoration: AdminTheme.inputDecoration(hintText: "Tipo"),
                  items: const [
                    DropdownMenuItem(
                      value: 'ingreso',
                      child: Text("Ingreso (Entrada de stock)"),
                    ),
                    DropdownMenuItem(
                      value: 'egreso',
                      child: Text("Egreso (Salida de stock)"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _type = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedProductId,
                  dropdownColor: AdminTheme.cardBgElevated,
                  decoration: AdminTheme.inputDecoration(hintText: "Selecciona producto"),
                  items: products.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(
                        "${p.sku != null ? '${p.sku} · ' : ''}${p.name}",
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProductId = val;
                      _selectedVariantName = null;
                    });
                  },
                  validator: (value) => value == null ? "Requerido" : null,
                ),
                const SizedBox(height: 16),
                if (selectedProduct != null) ...[
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedVariantName,
                    dropdownColor: AdminTheme.cardBgElevated,
                    decoration: AdminTheme.inputDecoration(hintText: "Selecciona variante"),
                    items: selectedProduct.variants.map((v) {
                      return DropdownMenuItem<String>(
                        value: v.name,
                        child: Text(
                          "${v.name} (Stock actual: ${v.stock})",
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedVariantName = val;
                      });
                    },
                    validator: (value) => value == null ? "Requerido" : null,
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: "1",
                        keyboardType: TextInputType.number,
                        decoration: AdminTheme.inputDecoration(hintText: "Cantidad"),
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Requerido";
                          final q = int.tryParse(value);
                          if (q == null || q <= 0) return "Debe ser > 0";
                          if (_type == 'egreso' && selectedVariant != null) {
                            if (selectedVariant.stock < q) {
                              return "Stock disp: ${selectedVariant.stock}";
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _quantity = int.tryParse(value) ?? 1;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: AdminTheme.inputDecoration(hintText: "Referencia (ej: OC-102)"),
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                        onChanged: (value) {
                          _reference = value;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: AdminTheme.inputDecoration(hintText: "Motivo (ej: Compra, Ajuste)"),
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                  onChanged: (value) {
                    _reason = value;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      style: AdminTheme.outlinedButton(),
                      child: const Text("Cancelar"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: AdminTheme.primaryButton(),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Guardar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null || _selectedVariantName == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.uid ?? 'admin';
      final userName = auth.user?.displayName ?? 'Admin';

      final stockMovementProvider = context.read<StockMovementProvider>();
      final productProvider = context.read<ProductProvider>();

      final product = productProvider.products.firstWhere((p) => p.id == _selectedProductId);
      final variant = product.variants.firstWhere((v) => v.name == _selectedVariantName);

      await stockMovementProvider.registerMovement(
        businessSlug: widget.businessSlug,
        productId: product.id,
        variantName: variant.name,
        type: _type,
        quantity: _quantity,
        reason: _reason.trim().isEmpty ? null : _reason.trim(),
        reference: _reference.trim().isEmpty ? null : _reference.trim(),
        userId: userId,
        userName: userName,
        currentProducts: productProvider.products,
        onUpdateProduct: (updatedProduct) =>
            productProvider.updateProduct(widget.businessSlug, updatedProduct),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Movimiento registrado con éxito")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: AdminTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
