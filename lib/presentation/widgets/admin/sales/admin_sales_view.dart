import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/presentation/providers/sales_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'create_sale_dialog.dart';
import 'ticket_print_view.dart';

class AdminSalesView extends StatefulWidget {
  final String businessSlug;
  const AdminSalesView({super.key, required this.businessSlug});

  @override
  State<AdminSalesView> createState() => _AdminSalesViewState();
}

class _AdminSalesViewState extends State<AdminSalesView> {
  String _documentFilter = 'all';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().loadSales(widget.businessSlug);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showTicketDialog(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => TicketPrintView(sale: sale),
    );
  }

  void _openCreateSaleDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateSaleDialog(businessSlug: widget.businessSlug),
    );
    if (result == true && mounted) {
      context.read<SalesProvider>().loadSales(widget.businessSlug);
    }
  }

  Widget _buildTab(String label, String value) {
    final isSelected = _documentFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: TextStyle(
            color: isSelected ? Colors.white : AdminTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _documentFilter = value;
          });
        }
      },
      selectedColor: AdminTheme.accent,
      backgroundColor: AdminTheme.inputFill,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AdminTheme.accent : AdminTheme.border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<SalesProvider>();
    final list = salesProvider.sales;
    final isLoading = salesProvider.isLoading;

    final query = _searchCtrl.text.toLowerCase();
    final filtered = list.where((s) {
      final matchesSearch = s.number.toLowerCase().contains(query) ||
          s.customerName.toLowerCase().contains(query) ||
          s.customerDoc.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      if (_documentFilter == 'all') return true;
      return s.documentType == _documentFilter;
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
              'Ventas y Comprobantes',
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Historial de facturación y emisión de boletas/facturas.',
              style: AdminTheme.bodySmall(),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _openCreateSaleDialog,
            icon: const Icon(Icons.add),
            style: AdminTheme.primaryButton(),
            label: Text(
              'Nueva Venta',
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
                        onChanged: (val) => setState(() {}),
                        decoration: AdminTheme.inputDecoration(
                          hintText: 'Buscar por número de comprobante o cliente...',
                          prefixIcon: Icon(Icons.search, color: AdminTheme.textMuted),
                        ),
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTab('Todos', 'all'),
                          const SizedBox(width: 8),
                          _buildTab('Boletas', 'boleta'),
                          const SizedBox(width: 8),
                          _buildTab('Facturas', 'factura'),
                          const SizedBox(width: 8),
                          _buildTab('Notas Venta', 'nota_venta'),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: AdminTheme.cardDecoration(),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AdminTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'No se encontraron ventas',
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza emitiendo una nueva venta con el botón superior.',
            style: AdminTheme.bodySmall(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<Sale> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final sale = items[index];
        final dateStr =
            "${sale.createdAt.day.toString().padLeft(2, '0')}/${sale.createdAt.month.toString().padLeft(2, '0')}/${sale.createdAt.year.toString().substring(2)}";

        return Container(
          decoration: AdminTheme.cardDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sale.number,
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sale.documentType == 'factura'
                          ? Colors.purple.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sale.documentType.toUpperCase(),
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: sale.documentType == 'factura' ? Colors.purple : Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildSunatStatus(sale),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Fecha: $dateStr',
                style: AdminTheme.caption(),
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _showTicketDialog(sale),
                    icon: const Icon(Icons.print, size: 18),
                    color: AdminTheme.textSecondary,
                    tooltip: 'Imprimir Ticket',
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => context.push("/${widget.businessSlug}/admin/sales/${sale.id}"),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Ver Factura'),
                    style: TextButton.styleFrom(foregroundColor: AdminTheme.accent),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<Sale> items) {
    return Container(
      width: double.infinity,
      decoration: AdminTheme.cardDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
          showCheckboxColumn: false,
          headingRowColor: WidgetStateProperty.all(AdminTheme.surface),
          columns: [
            _col('Nro Comprobante'),
            _col('Tipo'),
            _col('SUNAT'),
            _col('Cliente'),
            _col('Documento'),
            _col('Fecha'),
            _col('Método Pago'),
            _col('Total'),
            _col('Acción'),
          ],
          rows: items.map((sale) {
            final dateStr =
                "${sale.createdAt.day.toString().padLeft(2, '0')}/${sale.createdAt.month.toString().padLeft(2, '0')}/${sale.createdAt.year.toString().substring(2)} ${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}";

            return DataRow(
              onSelectChanged: (_) => context.push("/${widget.businessSlug}/admin/sales/${sale.id}"),
              cells: [
                DataCell(Text(sale.number, style: _cellStyle(fontWeight: FontWeight.bold))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sale.documentType == 'factura'
                          ? Colors.purple.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sale.documentType.toUpperCase(),
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: sale.documentType == 'factura' ? Colors.purple : Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(_buildSunatStatus(sale)),
                DataCell(Text(sale.customerName, style: _cellStyle())),
                DataCell(Text(sale.customerDoc, style: _cellStyle())),
                DataCell(Text(dateStr, style: _cellStyle())),
                DataCell(Text(sale.paymentMethod, style: _cellStyle())),
                DataCell(
                  Text(
                    'S/ ${sale.total.toStringAsFixed(2)}',
                    style: _cellStyle(fontWeight: FontWeight.bold, color: AdminTheme.accent),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.print, color: AdminTheme.accent, size: 20),
                    onPressed: () => _showTicketDialog(sale),
                    tooltip: 'Ver e Imprimir',
                  ),
                ),
              ],
            );
          }).toList(),
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

  Widget _buildSunatStatus(Sale sale) {
    if (sale.sunatStatus == null) return const SizedBox.shrink();

    IconData icon;
    Color color;
    String tooltip;

    switch (sale.sunatStatus) {
      case 'accepted':
        icon = Icons.check_circle;
        color = Colors.green;
        tooltip = 'Aceptado por SUNAT';
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        tooltip = 'Rechazado por SUNAT: ${sale.sunatDescription ?? ""}';
      case 'pending':
        icon = Icons.schedule;
        color = Colors.orange;
        tooltip = 'Pendiente de respuesta SUNAT';
      default:
        return const SizedBox.shrink();
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: color, size: 18),
    );
  }

  TextStyle _cellStyle({FontWeight fontWeight = FontWeight.normal, Color? color}) {
    return GoogleFonts.getFont(
      FontNames.fontNameH2,
      textStyle: TextStyle(
        fontSize: 13,
        color: color ?? AdminTheme.textPrimary,
        fontWeight: fontWeight,
      ),
    );
  }
}
