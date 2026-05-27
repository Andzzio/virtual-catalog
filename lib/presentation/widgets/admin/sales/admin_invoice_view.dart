import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/utils/web_meta_utils.dart'
    if (dart.library.js_interop) 'package:virtual_catalog_app/config/utils/web_meta_utils_web.dart'
    if (dart.library.io) 'package:virtual_catalog_app/config/utils/web_meta_utils_stub.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/sales_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminInvoiceView extends StatefulWidget {
  final String businessSlug;
  final String saleId;

  const AdminInvoiceView({
    super.key,
    required this.businessSlug,
    required this.saleId,
  });

  @override
  State<AdminInvoiceView> createState() => _AdminInvoiceViewState();
}

class _AdminInvoiceViewState extends State<AdminInvoiceView> {
  String _selectedFormat = 'a4';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().loadSales(widget.businessSlug);
      context.read<BusinessProvider>().loadBusiness(widget.businessSlug);
    });
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final count = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(count, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black54),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<SalesProvider>();
    final businessProvider = context.watch<BusinessProvider>();

    if (salesProvider.isLoading || businessProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AdminTheme.surface,
        body: Center(child: CircularProgressIndicator(color: AdminTheme.accent)),
      );
    }

    final business = businessProvider.business;
    Sale? sale;
    try {
      sale = salesProvider.sales.firstWhere((s) => s.id == widget.saleId);
    } catch (_) {
      sale = null;
    }

    if (sale == null || business == null) {
      return Scaffold(
        backgroundColor: AdminTheme.surface,
        appBar: AppBar(
          backgroundColor: AdminTheme.cardBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AdminTheme.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            "No se encontró el comprobante o los datos del negocio.",
            style: TextStyle(color: AdminTheme.textSecondary),
          ),
        ),
      );
    }

    final dateStr =
        "${sale.createdAt.day.toString().padLeft(2, '0')}/${sale.createdAt.month.toString().padLeft(2, '0')}/${sale.createdAt.year}";
    final timeStr =
        "${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}";

    final documentTitle = sale.documentType == 'factura'
        ? "FACTURA ELECTRÓNICA"
        : sale.documentType == 'boleta'
            ? "BOLETA DE VENTA"
            : "NOTA DE VENTA";

    final isNotaVenta = sale.documentType.toLowerCase().trim().contains('nota');

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Comprobante ${sale.number}",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => context.push(
                "/${widget.businessSlug}/admin/sales/${widget.saleId}/package"),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AdminTheme.accent),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              "Sticker de empaque",
              style: GoogleFonts.getFont(FontNames.fontNameH2,
                  textStyle: const TextStyle(color: AdminTheme.accent)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              if (_selectedFormat == 'a4') {
                printSaleInvoice(sale!, business);
              } else {
                printSaleTicket(sale!, business);
              }
            },
            icon: const Icon(Icons.print_rounded, size: 18),
            style: AdminTheme.primaryButton(),
            label: Text(
              "Imprimir / PDF",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AdminTheme.border, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AdminTheme.cardBg,
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedFormat = 'a4'),
                        borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedFormat == 'a4' ? AdminTheme.accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
                          ),
                          child: Center(
                            child: Text(
                              "Formato A4",
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedFormat == 'a4' ? Colors.white : AdminTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedFormat = 'ticket'),
                        borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedFormat == 'ticket' ? AdminTheme.accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
                          ),
                          child: Center(
                            child: Text(
                              "Formato Ticket",
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedFormat == 'ticket' ? Colors.white : AdminTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: _selectedFormat == 'a4'
                  ? _buildA4Paper(sale, business, isNotaVenta, dateStr, timeStr, documentTitle)
                  : _buildTicketPaper(sale, business, isNotaVenta, dateStr, timeStr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildA4Paper(
    Sale sale,
    Business business,
    bool isNotaVenta,
    String dateStr,
    String timeStr,
    String documentTitle,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name.toUpperCase(),
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      business.address ?? 'Dirección no especificada',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    ),
                    Text(
                      "WhatsApp: ${business.whatsappNumber}",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    ),
                    if (business.ruc != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "RUC: ${business.ruc}",
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0F172A), width: 2),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                ),
                child: Column(
                  children: [
                    Text(
                      documentTitle,
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sale.number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CLIENTE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sale.customerName,
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (sale.customerDoc.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          "${sale.documentType == 'factura' ? 'RUC' : 'DNI'}: ${sale.customerDoc}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                      if (sale.customerAddress.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          sale.customerAddress,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "DETALLES DE EMISIÓN",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Fecha: $dateStr", style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    Text("Hora: $timeStr", style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    const SizedBox(height: 16),
                    const Text(
                      "MÉTODO DE PAGO",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sale.paymentMethod.toUpperCase(),
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(5.0),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(2.0),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFCBD5E1), width: 2)),
                ),
                children: [
                  _headerCell("Cant."),
                  _headerCell("Descripción"),
                  _headerCell("P. Unit.", isRight: true),
                  _headerCell("Total", isRight: true),
                ],
              ),
              ...sale.items.map((item) {
                return TableRow(
                  decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  children: [
                    _cell(item.quantity.toStringAsFixed(1), isMono: true),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (item.variantName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.variantName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _cell("S/ ${item.unitPrice.toStringAsFixed(2)}",
                        isMono: true, isRight: true),
                    _cell("S/ ${item.lineTotal.toStringAsFixed(2)}",
                        isMono: true, isRight: true, isBold: true),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 300,
              child: Column(
                children: [
                  if (!isNotaVenta) ...[
                    _totalsRow("Op. Gravadas",
                        "S/ ${sale.subtotal.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),
                    _totalsRow(
                        "IGV (18%)", "S/ ${sale.igv.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Color(0xFF0F172A), width: 2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TOTAL",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Text(
                          "S/ ${sale.total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (sale.notes.isNotEmpty) ...[
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: Color(0xFFCBD5E1))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "OBSERVACIONES",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sale.notes,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Text(
                  isNotaVenta
                      ? "Representación física de una Nota de Venta de uso interno · Emitido por CRM"
                      : "Representación impresa del comprobante electrónico · Emitido por CRM",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isNotaVenta) ...[
                  const SizedBox(height: 24),
                  Image.network(
                    "https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=${Uri.encodeComponent("${business.ruc ?? ''}|${sale.documentType == 'factura' ? '01' : '03'}|${sale.number.split('-')[0]}|${sale.number.split('-').length > 1 ? sale.number.split('-')[1] : ''}|${sale.igv.toStringAsFixed(2)}|${sale.total.toStringAsFixed(2)}|$dateStr|${sale.customerDoc.length == 11 ? '6' : '1'}|${sale.customerDoc}|")}",
                    width: 120,
                    height: 120,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketPaper(
    Sale sale,
    Business business,
    bool isNotaVenta,
    String dateStr,
    String timeStr,
  ) {
    final showQr = !isNotaVenta;
    final docTypeNum = sale.documentType == 'factura' ? '01' : '03';
    final numberParts = sale.number.split('-');
    final series = numberParts.isNotEmpty ? numberParts[0] : '';
    final correlative = numberParts.length > 1 ? numberParts[1] : '';

    final qrData = showQr
        ? "${business.ruc ?? ''}|$docTypeNum|$series|$correlative|${sale.igv.toStringAsFixed(2)}|${sale.total.toStringAsFixed(2)}|$dateStr|${sale.customerDoc.length == 11 ? '6' : '1'}|${sale.customerDoc}|"
        : "";
    final qrUrl = showQr
        ? "https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=${Uri.encodeComponent(qrData)}"
        : null;

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              business.name.toUpperCase(),
              style: GoogleFonts.courierPrime(
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (business.ruc != null) ...[
            const SizedBox(height: 2),
            Center(
              child: Text(
                'R.U.C. ${business.ruc!}',
                style: GoogleFonts.courierPrime(
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black),
                ),
              ),
            ),
          ],
          if (business.address != null) ...[
            const SizedBox(height: 2),
            Center(
              child: Text(
                business.address!,
                style: GoogleFonts.courierPrime(
                  textStyle: const TextStyle(fontSize: 10, color: Colors.black87),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 2),
          Center(
            child: Text(
              'WhatsApp: ${business.whatsappNumber}',
              style: GoogleFonts.courierPrime(
                textStyle: const TextStyle(fontSize: 10, color: Colors.black87),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          _buildDashedLine(),
          const SizedBox(height: 6),
          Center(
            child: Text(
              isNotaVenta
                  ? 'NOTA DE VENTA'
                  : sale.documentType == 'factura'
                      ? 'FACTURA ELECTRÓNICA'
                      : 'BOLETA DE VENTA ELECTRÓNICA',
              style: GoogleFonts.courierPrime(
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              'NRO: ${sale.number}',
              style: GoogleFonts.courierPrime(
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          _buildDashedLine(),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.8),
            },
            children: [
              TableRow(
                children: [
                  Text('Señores:', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black))),
                  Text(sale.customerName, style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, color: Colors.black))),
                ],
              ),
              if (!isNotaVenta || sale.customerDoc.isNotEmpty)
                TableRow(
                  children: [
                    Text(
                      isNotaVenta
                          ? 'DOC. IDENTIDAD:'
                          : sale.customerDoc.length == 11
                              ? 'R.U.C.:'
                              : 'D.N.I.:',
                      style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    Text(sale.customerDoc, style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, color: Colors.black))),
                  ],
                ),
              if (sale.customerAddress.isNotEmpty)
                TableRow(
                  children: [
                    Text('Dirección:', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black))),
                    Text(sale.customerAddress, style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, color: Colors.black))),
                  ],
                ),
              TableRow(
                children: [
                  Text('F. Emisión:', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black))),
                  Text('$dateStr $timeStr', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, color: Colors.black))),
                ],
              ),
              TableRow(
                children: [
                  Text('Pago:', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black))),
                  Text(sale.paymentMethod.toUpperCase(), style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, color: Colors.black))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDashedLine(),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.2),
              1: FlexColumnWidth(0.6),
              2: FlexColumnWidth(0.8),
              3: FlexColumnWidth(0.9),
            },
            children: [
              TableRow(
                children: [
                  Text('PRODUCTO', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black))),
                  Text('CANT', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)), textAlign: TextAlign.center),
                  Text('PRECIO', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)), textAlign: TextAlign.right),
                  Text('TOTAL', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)), textAlign: TextAlign.right),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...sale.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.2),
                  1: FlexColumnWidth(0.6),
                  2: FlexColumnWidth(0.8),
                  3: FlexColumnWidth(0.9),
                },
                children: [
                  TableRow(
                    children: [
                      Text(
                        '${item.productName}${item.variantName.isNotEmpty ? " (${item.variantName})" : ""}',
                        style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, color: Colors.black)),
                      ),
                      Text(
                        item.quantity.toStringAsFixed(1),
                        style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, color: Colors.black)),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        item.unitPrice.toStringAsFixed(2),
                        style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, color: Colors.black)),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        item.lineTotal.toStringAsFixed(2),
                        style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, color: Colors.black)),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildDashedLine(),
          const SizedBox(height: 8),
          if (!isNotaVenta) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('OP. GRAVADA:', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, color: Colors.black))),
                Text('S/ ${sale.subtotal.toStringAsFixed(2)}', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, color: Colors.black))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('I.G.V. (18%):', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, color: Colors.black))),
                Text('S/ ${sale.igv.toStringAsFixed(2)}', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, color: Colors.black))),
              ],
            ),
          ],
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL VENTA:', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black))),
              Text('S/ ${sale.total.toStringAsFixed(2)}', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black))),
            ],
          ),
          const SizedBox(height: 6),
          if (sale.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDashedLine(),
            const SizedBox(height: 8),
            Text(
              'Notas:',
              style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            Text(
              sale.notes,
              style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, color: Colors.black)),
            ),
          ],
          const SizedBox(height: 8),
          _buildDashedLine(),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'VENDEDOR(A): ${sale.userName.toUpperCase()}',
              style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 9, color: Colors.black)),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              isNotaVenta
                  ? 'Representación física de una Nota de Venta de uso interno.'
                  : 'Representación impresa de la ${sale.documentType == 'factura' ? 'Factura' : 'Boleta'} Electrónica.',
              style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 9, color: Colors.black54)),
              textAlign: TextAlign.center,
            ),
          ),
          if (isNotaVenta)
            Center(
              child: Text(
                'Sin valor tributario.',
                style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 9, color: Colors.black54)),
              ),
            ),
          Center(
            child: Text(
              'Gracias por su preferencia.',
              style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 9, color: Colors.black54)),
              textAlign: TextAlign.center,
            ),
          ),
          if (showQr && qrUrl != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Image.network(
                qrUrl,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerCell(String text, {bool isRight = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: Color(0xFF475569),
          ),
        ),
        textAlign: isRight ? TextAlign.right : TextAlign.left,
      ),
    );
  }

  Widget _cell(String text,
      {bool isBold = false, bool isMono = false, bool isRight = false}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          text,
          style: GoogleFonts.getFont(
            isMono ? FontNames.fontNameP : FontNames.fontNameH2,
            textStyle: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: isMono ? 'monospace' : null,
              color: const Color(0xFF0F172A),
            ),
          ),
          textAlign: isRight ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }

  Widget _totalsRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'monospace',
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
