import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/stock_movement.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/stock_movement_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'register_movement_dialog.dart';

class AdminInventoryView extends StatefulWidget {
  final String businessSlug;
  const AdminInventoryView({super.key, required this.businessSlug});

  @override
  State<AdminInventoryView> createState() => _AdminInventoryViewState();
}

class _AdminInventoryViewState extends State<AdminInventoryView> {
  String _filter = 'all';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockMovementProvider>().loadMovements(widget.businessSlug);
      context.read<ProductProvider>().loadProducts(widget.businessSlug);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockMovementProvider = context.watch<StockMovementProvider>();
    final list = stockMovementProvider.movements;
    final isLoading = stockMovementProvider.isLoading;

    final query = _searchCtrl.text.toLowerCase();
    final filtered = list.where((m) {
      final matchesSearch = m.productName.toLowerCase().contains(query) ||
          (m.productSku != null && m.productSku!.toLowerCase().contains(query)) ||
          m.variantName.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      if (_filter == 'all') return true;
      return m.type == _filter;
    }).toList();

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.cardBg,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AdminTheme.border, height: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Inventario",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "Historial de Kardex y movimientos de mercadería.",
              style: AdminTheme.bodySmall(),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => RegisterMovementDialog(
                  businessSlug: widget.businessSlug,
                ),
              );
            },
            icon: const Icon(Icons.add),
            style: AdminTheme.primaryButton(),
            label: Text(
              "Nuevo Movimiento",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < AdminTheme.breakpointMobile;
          final padding = isMobile ? 12.0 : 24.0;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: AdminTheme.cardDecoration(),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (value) => setState(() {}),
                        decoration: AdminTheme.inputDecoration(
                          hintText: "Buscar por producto, SKU o variante...",
                          prefixIcon: Icon(Icons.search, color: AdminTheme.textMuted),
                        ),
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTab("Todos", 'all'),
                          const SizedBox(width: 8),
                          _buildTab("Ingresos", 'ingreso'),
                          const SizedBox(width: 8),
                          _buildTab("Egresos", 'egreso'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? _buildEmptyState()
                          : isMobile
                              ? _buildMobileList(filtered)
                              : _buildDesktopTable(filtered),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AdminTheme.accent : AdminTheme.cardBgElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AdminTheme.accent : AdminTheme.border,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AdminTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AdminTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            "Sin movimientos",
            style: AdminTheme.heading2().copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "No se encontraron transacciones en el Kardex para este filtro.",
            style: AdminTheme.bodySmall(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<StockMovement> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final m = items[index];
        final isIngreso = m.type == 'ingreso';

        return GestureDetector(
          onTap: () => _showMovementDetail(context, m),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: AdminTheme.cardDecoration(elevated: false),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      m.productName,
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isIngreso
                          ? AdminTheme.success.withValues(alpha: 0.15)
                          : AdminTheme.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 12,
                          color: isIngreso ? AdminTheme.success : AdminTheme.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          m.type.toUpperCase(),
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isIngreso ? AdminTheme.success : AdminTheme.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Var: ${m.variantName}",
                    style: AdminTheme.bodySmall(),
                  ),
                  Text(
                    "Sku: ${m.productSku ?? '—'}",
                    style: AdminTheme.caption(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Cant: ",
                        style: AdminTheme.caption(),
                      ),
                      Text(
                        "${isIngreso ? '+' : '-'}${m.quantity}",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isIngreso ? AdminTheme.success : AdminTheme.danger,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Stock post: ",
                        style: AdminTheme.caption(),
                      ),
                      Text(
                        "${m.stockAfter}",
                        style: AdminTheme.kpiValue().copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              if (m.reason != null || m.reference != null) ...[
                const SizedBox(height: 6),
                Text(
                  "Motivo: ${m.reason ?? '—'}${m.reference != null ? ' (Ref: ${m.reference})' : ''}",
                  style: AdminTheme.caption().copyWith(color: AdminTheme.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  },
    );
  }

  Widget _buildDesktopTable(List<StockMovement> items) {
    return Container(
      width: double.infinity,
      decoration: AdminTheme.cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: WidgetStatePropertyAll(AdminTheme.cardBgElevated),
              columnSpacing: 24,
              columns: [
                _col("SKU"),
                _col("Producto"),
                _col("Variante"),
                _col("Tipo"),
                _col("Cantidad"),
                _col("Stock Post"),
                _col("Motivo / Referencia"),
                _col("Fecha"),
                _col("Usuario"),
              ],
              rows: items.map((m) {
                final isIngreso = m.type == 'ingreso';
                final dateStr =
                    "${m.createdAt.day.toString().padLeft(2, '0')}/${m.createdAt.month.toString().padLeft(2, '0')}/${m.createdAt.year.toString().substring(2)} ${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}";

                return DataRow(
                  onSelectChanged: (_) => _showMovementDetail(context, m),
                  cells: [
                    DataCell(Text(m.productSku ?? '—', style: _cellStyle())),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          m.productName,
                          style: _cellStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(m.variantName, style: _cellStyle())),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isIngreso
                              ? AdminTheme.success.withValues(alpha: 0.1)
                              : AdminTheme.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          m.type.toUpperCase(),
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isIngreso ? AdminTheme.success : AdminTheme.warning,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${isIngreso ? '+' : '-'}${m.quantity}",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIngreso ? AdminTheme.success : AdminTheme.danger,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${m.stockAfter}",
                        style: AdminTheme.kpiValue().copyWith(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${m.reason ?? '—'}${m.reference != null ? ' (Ref: ${m.reference})' : ''}",
                        style: _cellStyle(),
                      ),
                    ),
                    DataCell(Text(dateStr, style: _cellStyle())),
                    DataCell(Text(m.userName, style: _cellStyle())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _col(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AdminTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  TextStyle _cellStyle({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
    String? fontFamily,
  }) {
    return GoogleFonts.getFont(
      fontFamily ?? FontNames.fontNameH2,
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AdminTheme.textPrimary,
      ),
    );
  }

  void _showMovementDetail(BuildContext context, StockMovement m) {
    final isIngreso = m.type == 'ingreso';
    final dateStr =
        "${m.createdAt.day.toString().padLeft(2, '0')}/${m.createdAt.month.toString().padLeft(2, '0')}/${m.createdAt.year} ${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminTheme.radiusLg),
          ),
          backgroundColor: AdminTheme.cardBg,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Detalle del Movimiento",
                      style: AdminTheme.heading2(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isIngreso
                          ? AdminTheme.success.withValues(alpha: 0.1)
                          : AdminTheme.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isIngreso ? "INGRESO" : "EGRESO",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isIngreso ? AdminTheme.success : AdminTheme.warning,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${isIngreso ? '+' : '-'}${m.quantity}",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isIngreso ? AdminTheme.success : AdminTheme.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _detailRow("Producto", m.productName, isBold: true),
                _detailRow("Variante", m.variantName),
                _detailRow("SKU", m.productSku ?? "—"),
                _detailRow("Stock Posterior", "${m.stockAfter}"),
                _detailRow("Fecha y Hora", dateStr),
                _detailRow("Usuario", m.userName),
                if (m.reference != null && m.reference!.isNotEmpty)
                  _detailRow("Referencia", m.reference!),
                if (m.reason != null && m.reason!.isNotEmpty)
                  _detailRow("Motivo", m.reason!),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AdminTheme.primaryButton(),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Cerrar",
                      style: GoogleFonts.getFont(FontNames.fontNameH2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: TextStyle(
                  fontSize: 13,
                  color: AdminTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: TextStyle(
                  fontSize: 13,
                  color: AdminTheme.textPrimary,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
