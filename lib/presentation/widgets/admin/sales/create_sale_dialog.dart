import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/data/services/dni_ruc_service.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';
import 'package:virtual_catalog_app/domain/entities/sale_item.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/sales_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class CreateSaleDialog extends StatefulWidget {
  final String businessSlug;
  const CreateSaleDialog({super.key, required this.businessSlug});

  @override
  State<CreateSaleDialog> createState() => _CreateSaleDialogState();
}

class _CreateSaleDialogState extends State<CreateSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dniRucService = DniRucService();

  late String _documentType;
  final _docCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedPaymentMethod;
  final List<SaleItem> _items = [];

  Product? _selectedProduct;
  ProductVariant? _selectedVariant;
  final _qtyCtrl = TextEditingController(text: '1');

  bool _isQueryingDoc = false;
  bool _isSubmitting = false;

  // NC/ND fields
  String? _motivoCodigo;
  final _motivoDescCtrl = TextEditingController();
  final _refDocCtrl = TextEditingController();
  String _refDocType = '01'; // '01' = factura, '03' = boleta

  @override
  void initState() {
    super.initState();
    final business = context.read<BusinessProvider>().business;
    final hasNubefact = business != null &&
        business.nubefactUrl != null &&
        business.nubefactUrl!.isNotEmpty &&
        business.nubefactToken != null &&
        business.nubefactToken!.isNotEmpty;
    final hasSunatDirect = business != null &&
        business.hasCertificate == true &&
        business.ruc != null &&
        business.ruc!.isNotEmpty &&
        business.sunatUser != null &&
        business.sunatUser!.isNotEmpty &&
        business.sunatPassword != null &&
        business.sunatPassword!.isNotEmpty &&
        business.sunatPfxPassword != null &&
        business.sunatPfxPassword!.isNotEmpty;
    _documentType = (hasNubefact || hasSunatDirect) ? 'boleta' : 'nota_venta';
  }

  @override
  void dispose() {
    _docCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    _qtyCtrl.dispose();
    _motivoDescCtrl.dispose();
    _refDocCtrl.dispose();
    super.dispose();
  }

  Future<void> _queryDocument(String val, String token) async {
    if (val.length != 8 && val.length != 11) return;

    setState(() => _isQueryingDoc = true);
    try {
      final res = await _dniRucService.queryDocument(docNumber: val, token: token);
      setState(() {
        _nameCtrl.text = res.name;
        if (res.address != null) {
          _addressCtrl.text = res.address!;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo consultar el documento: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isQueryingDoc = false);
      }
    }
  }

  void _addItem() {
    if (_selectedProduct == null || _selectedVariant == null) return;
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) return;

    if (_selectedVariant!.stock < qty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock insuficiente para la cantidad solicitada')),
      );
      return;
    }

    final price = _selectedVariant!.discountPrice ?? _selectedVariant!.price;
    final lineTotal = price * qty;

    final existingIndex = _items.indexWhere(
      (item) => item.productId == _selectedProduct!.id && item.variantName == _selectedVariant!.name,
    );

    setState(() {
      if (existingIndex != -1) {
        final existing = _items[existingIndex];
        final newQty = existing.quantity + qty;
        if (_selectedVariant!.stock < newQty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La cantidad total acumulada supera el stock disponible')),
          );
          return;
        }
        _items[existingIndex] = SaleItem(
          productId: existing.productId,
          productName: existing.productName,
          productSku: existing.productSku,
          variantName: existing.variantName,
          quantity: newQty,
          unitPrice: existing.unitPrice,
          lineTotal: existing.unitPrice * newQty,
        );
      } else {
        _items.add(
          SaleItem(
            productId: _selectedProduct!.id,
            productName: _selectedProduct!.name,
            productSku: _selectedVariant!.sku ?? _selectedProduct!.sku,
            variantName: _selectedVariant!.name,
            quantity: qty,
            unitPrice: price,
            lineTotal: lineTotal,
          ),
        );
      }

      _selectedProduct = null;
      _selectedVariant = null;
      _qtyCtrl.text = '1';
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  String? _extractRefSerie() {
    if (_documentType != 'nota_credito' && _documentType != 'nota_debito') return null;
    final parts = _refDocCtrl.text.trim().split('-');
    return parts.isNotEmpty ? parts[0] : null;
  }

  int? _extractRefNumero() {
    if (_documentType != 'nota_credito' && _documentType != 'nota_debito') return null;
    final parts = _refDocCtrl.text.trim().split('-');
    if (parts.length > 1) return int.tryParse(parts[1]);
    return null;
  }

  void _selectExistingSale(BuildContext context) {
    final salesProvider = context.read<SalesProvider>();
    final electronicSales = salesProvider.sales
        .where((s) => s.documentType == 'boleta' || s.documentType == 'factura')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (electronicSales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay boletas o facturas emitidas')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminTheme.radiusLg)),
        backgroundColor: AdminTheme.cardBg,
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Seleccionar comprobante',
                style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: electronicSales.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final s = electronicSales[i];
                    final tipo = s.documentType == 'factura' ? 'FACTURA' : 'BOLETA';
                    return ListTile(
                      dense: true,
                      title: Text('${s.number}  -  ${s.customerName}', style: GoogleFonts.getFont(FontNames.fontNameH2, fontSize: 13)),
                      subtitle: Text('${s.customerDoc}  |  S/ ${s.total.toStringAsFixed(2)}', style: GoogleFonts.getFont(FontNames.fontNameH2, fontSize: 11, color: AdminTheme.textMuted)),
                      trailing: Text(tipo, style: GoogleFonts.getFont(FontNames.fontNameH2, fontSize: 10, color: s.documentType == 'factura' ? Colors.purple : Colors.blue)),
                      onTap: () {
                        setState(() {
                          _refDocType = s.documentType == 'factura' ? '01' : '03';
                          _refDocCtrl.text = s.number;
                          _docCtrl.text = s.customerDoc;
                          _nameCtrl.text = s.customerName;
                          _addressCtrl.text = s.customerAddress;
                          _items.clear();
                          for (var item in s.items) {
                            _items.add(SaleItem(
                              productId: item.productId,
                              productName: item.productName,
                              productSku: item.productSku,
                              variantName: item.variantName,
                              quantity: item.quantity,
                              unitPrice: item.unitPrice,
                              lineTotal: item.lineTotal,
                            ));
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un producto a la venta')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final businessProvider = context.read<BusinessProvider>();
    final productProvider = context.read<ProductProvider>();
    final salesProvider = context.read<SalesProvider>();

    setState(() => _isSubmitting = true);

    try {
      await salesProvider.emitSale(
        businessSlug: widget.businessSlug,
        customerName: _nameCtrl.text.trim(),
        customerDoc: _docCtrl.text.trim(),
        customerAddress: _addressCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        documentType: _documentType,
        paymentMethod: _selectedPaymentMethod ?? 'efectivo',
        items: _items,
        notes: _notesCtrl.text.trim(),
        userId: authProvider.user?.uid ?? '',
        userName: authProvider.user?.displayName ?? authProvider.user?.email ?? 'Administrador',
        currentProducts: productProvider.products,
        onUpdateProduct: (p) => productProvider.updateProduct(widget.businessSlug, p),
        business: businessProvider.business,
        motivoCodigo: (_documentType == 'nota_credito' || _documentType == 'nota_debito') ? _motivoCodigo : null,
        motivoDescripcion: (_documentType == 'nota_credito' || _documentType == 'nota_debito') ? _motivoDescCtrl.text.trim() : null,
        refDocSerie: _extractRefSerie(),
        refDocNumero: _extractRefNumero(),
        refDocType: (_documentType == 'nota_credito' || _documentType == 'nota_debito') ? _refDocType : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta registrada con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al emitir la venta: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = context.watch<BusinessProvider>();
    final business = businessProvider.business;
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products.where((p) => p.isAvailable).toList();

    final token = business?.apisPeruToken ?? '';
    final hasNubefact = business != null &&
        business.nubefactUrl != null &&
        business.nubefactUrl!.isNotEmpty &&
        business.nubefactToken != null &&
        business.nubefactToken!.isNotEmpty;
    final hasSunatDirect = business != null &&
        business.hasCertificate == true &&
        business.ruc != null &&
        business.ruc!.isNotEmpty &&
        business.sunatUser != null &&
        business.sunatUser!.isNotEmpty &&
        business.sunatPassword != null &&
        business.sunatPassword!.isNotEmpty &&
        business.sunatPfxPassword != null &&
        business.sunatPfxPassword!.isNotEmpty;
    final canEmitElectronic = hasNubefact || hasSunatDirect;
    final paymentMethods = business?.paymentMethods ?? [];

    if (_selectedPaymentMethod == null && paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = paymentMethods.first.name;
    }

    final total = _items.fold<double>(0.0, (acc, item) => acc + item.lineTotal);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminTheme.radiusLg)),
      backgroundColor: AdminTheme.cardBg,
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nueva Venta / Emisión',
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AdminTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Datos del Comprobante y Cliente',
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AdminTheme.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _documentType,
                                    isExpanded: true,
                                    dropdownColor: AdminTheme.cardBgElevated,
                                    decoration: AdminTheme.inputDecoration(hintText: 'Tipo Comprobante'),
                                    style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(color: AdminTheme.textPrimary)),
                                    items: canEmitElectronic
                                        ? const [
                                            DropdownMenuItem(value: 'boleta', child: Text('Boleta de Venta')),
                                            DropdownMenuItem(value: 'factura', child: Text('Factura')),
                                            DropdownMenuItem(value: 'nota_credito', child: Text('Nota de Crédito')),
                                            DropdownMenuItem(value: 'nota_debito', child: Text('Nota de Débito')),
                                            DropdownMenuItem(value: 'nota_venta', child: Text('Nota de Venta')),
                                          ]
                                        : const [
                                            DropdownMenuItem(value: 'nota_venta', child: Text('Nota de Venta')),
                                          ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _documentType = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _docCtrl,
                                    decoration: AdminTheme.inputDecoration(
                                      hintText: _documentType == 'boleta'
                                          ? 'DNI (8 dígitos)'
                                          : _documentType == 'factura'
                                              ? 'RUC (11 dígitos)'
                                              : _documentType == 'nota_credito' || _documentType == 'nota_debito'
                                                  ? (_refDocType == '01' ? 'RUC (11 dígitos)' : 'DNI (8 dígitos)')
                                                  : 'Documento (Opcional)',
                                      suffixIcon: _isQueryingDoc
                                          ? const Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                            )
                                          : token.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.search, color: AdminTheme.accent),
                                                  onPressed: () => _queryDocument(_docCtrl.text.trim(), token),
                                                )
                                              : null,
                                    ),
                                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      final shouldQuery = (_documentType == 'boleta' && val.length == 8) ||
                                          (_documentType == 'factura' && val.length == 11) ||
                                          ((_documentType == 'nota_credito' || _documentType == 'nota_debito') &&
                                              ((_refDocType == '01' && val.length == 11) ||
                                                  (_refDocType == '03' && val.length == 8)));
                                      if (token.isNotEmpty && shouldQuery) {
                                        _queryDocument(val, token);
                                      }
                                    },
                                    validator: (v) {
                                      if (_documentType == 'nota_venta') return null;
                                      if (v == null || v.trim().isEmpty) return 'Requerido';
                                      if (_documentType == 'boleta' && v.trim().length != 8) return 'Debe tener 8 dígitos';
                                      if (_documentType == 'factura' && v.trim().length != 11) return 'Debe tener 11 dígitos';
                                      if (_documentType == 'nota_credito' || _documentType == 'nota_debito') {
                                        if (_refDocType == '01' && v.trim().length != 11) return 'Debe tener 11 dígitos (RUC)';
                                        if (_refDocType == '03' && v.trim().length != 8) return 'Debe tener 8 dígitos (DNI)';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: AdminTheme.inputDecoration(
                                hintText: _documentType == 'boleta'
                                    ? 'Nombre del Cliente'
                                    : _documentType == 'factura' || _documentType == 'nota_credito' || _documentType == 'nota_debito'
                                        ? 'Razón Social'
                                        : 'Cliente / Nombre',
                              ),
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _addressCtrl,
                              decoration: AdminTheme.inputDecoration(hintText: 'Dirección (Opcional)'),
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                            if (_documentType == 'nota_credito' || _documentType == 'nota_debito') ...[
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                dropdownColor: AdminTheme.cardBgElevated,
                                decoration: AdminTheme.inputDecoration(hintText: 'Motivo'),
                                style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(color: AdminTheme.textPrimary)),
                                items: const [
                                  DropdownMenuItem(value: '01', child: Text('01 - Anulación')),
                                  DropdownMenuItem(value: '02', child: Text('02 - Devolución total')),
                                  DropdownMenuItem(value: '03', child: Text('03 - Bonificación')),
                                  DropdownMenuItem(value: '04', child: Text('04 - Disminución valor')),
                                  DropdownMenuItem(value: '05', child: Text('05 - Devolución item')),
                                  DropdownMenuItem(value: '06', child: Text('06 - Descuento global')),
                                  DropdownMenuItem(value: '07', child: Text('07 - Ajuste operaciones')),
                                  DropdownMenuItem(value: '08', child: Text('08 - Corrección descripción')),
                                ],
                                onChanged: (val) => setState(() => _motivoCodigo = val),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _motivoDescCtrl,
                                decoration: AdminTheme.inputDecoration(hintText: 'Descripción del motivo'),
                                style: GoogleFonts.getFont(FontNames.fontNameH2),
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(value: '01', label: Text('Factura'), icon: Icon(Icons.description, size: 16)),
                                  ButtonSegment(value: '03', label: Text('Boleta'), icon: Icon(Icons.receipt, size: 16)),
                                ],
                                selected: {_refDocType},
                                onSelectionChanged: (selected) {
                                  setState(() => _refDocType = selected.first);
                                },
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                  textStyle: WidgetStatePropertyAll(
                                    GoogleFonts.getFont(FontNames.fontNameH2, fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _refDocCtrl,
                                decoration: AdminTheme.inputDecoration(
                                  hintText: _refDocType == '01' ? 'Nro Factura (ej: F001-00000001)' : 'Nro Boleta (ej: B001-00000001)',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search, size: 20),
                                    onPressed: () => _selectExistingSale(context),
                                    tooltip: 'Seleccionar venta existente',
                                  ),
                                ),
                                style: GoogleFonts.getFont(FontNames.fontNameH2),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido para NC/ND' : null,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneCtrl,
                                    decoration: AdminTheme.inputDecoration(hintText: 'Teléfono (Opcional)'),
                                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedPaymentMethod,
                                    isExpanded: true,
                                    dropdownColor: AdminTheme.cardBgElevated,
                                    decoration: AdminTheme.inputDecoration(hintText: 'Método de Pago'),
                                    style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(color: AdminTheme.textPrimary)),
                                    items: paymentMethods.isNotEmpty
                                        ? paymentMethods.map((m) => DropdownMenuItem(value: m.name, child: Text(m.name))).toList()
                                        : const [
                                            DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                                            DropdownMenuItem(value: 'transferencia', child: Text('Transferencia')),
                                          ],
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedPaymentMethod = val;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Agregar Producto',
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AdminTheme.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Autocomplete<Product>(
                              displayStringForOption: (Product option) => option.name,
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<Product>.empty();
                                }
                                return products.where((Product option) {
                                  return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                });
                              },
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: AdminTheme.inputDecoration(
                                    hintText: 'Buscar producto por nombre...',
                                    prefixIcon: const Icon(Icons.search, size: 18),
                                  ),
                                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                                );
                              },
                              onSelected: (Product selection) {
                                setState(() {
                                  _selectedProduct = selection;
                                  _selectedVariant = selection.variants.isNotEmpty ? selection.variants.first : null;
                                });
                              },
                            ),
                            if (_selectedProduct != null && _selectedProduct!.variants.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<ProductVariant>(
                                      initialValue: _selectedVariant,
                                      isExpanded: true,
                                      dropdownColor: AdminTheme.cardBgElevated,
                                      decoration: AdminTheme.inputDecoration(hintText: 'Variante / SKU'),
                                      style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(color: AdminTheme.textPrimary)),
                                      items: _selectedProduct!.variants.map((v) {
                                        return DropdownMenuItem(
                                          value: v,
                                          child: Text(
                                            '${v.name} (Stock: ${v.stock}) - S/ ${(v.discountPrice ?? v.price).toStringAsFixed(2)}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedVariant = val;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: _qtyCtrl,
                                      decoration: AdminTheme.inputDecoration(hintText: 'Cant.'),
                                      style: GoogleFonts.getFont(FontNames.fontNameH2),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: _addItem,
                                    style: AdminTheme.primaryButton(),
                                    child: const Text('+ Add'),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _notesCtrl,
                              decoration: AdminTheme.inputDecoration(hintText: 'Notas o indicaciones adicionales (Opcional)'),
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const VerticalDivider(),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalle del Comprobante',
                            style: GoogleFonts.getFont(
                              FontNames.fontNameH2,
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AdminTheme.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AdminTheme.border),
                                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                                color: AdminTheme.surface,
                              ),
                              child: _items.isEmpty
                                  ? const Center(child: Text('No hay productos agregados', style: TextStyle(color: AdminTheme.textSecondary)))
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(12),
                                      itemCount: _items.length,
                                      separatorBuilder: (_, _) => const Divider(),
                                      itemBuilder: (context, index) {
                                        final item = _items[index];
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.productName,
                                                    style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                  ),
                                                  Text(
                                                    '${item.variantName} x ${item.quantity}',
                                                    style: AdminTheme.caption(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'S/ ${item.lineTotal.toStringAsFixed(2)}',
                                              style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                              onPressed: () => _removeItem(index),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AdminTheme.cardBgElevated,
                              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                              border: Border.all(color: AdminTheme.border),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Op. Gravada:', style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary)),
                                    Text('S/ ${(total / 1.18).toStringAsFixed(2)}', style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(fontSize: 13))),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('I.G.V. (18%):', style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary)),
                                    Text('S/ ${(total - (total / 1.18)).toStringAsFixed(2)}', style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(fontSize: 13))),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'TOTAL:',
                                      style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ),
                                    Text(
                                      'S/ ${total.toStringAsFixed(2)}',
                                      style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminTheme.accent)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: AdminTheme.primaryButton(),
                              child: _isSubmitting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Emitir Comprobante', style: GoogleFonts.getFont(FontNames.fontNameH2)),
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
        ),
      ),
    );
  }
}
