import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/utils/web_meta_utils.dart'
    if (dart.library.js_interop) 'package:virtual_catalog_app/config/utils/web_meta_utils_web.dart'
    if (dart.library.io) 'package:virtual_catalog_app/config/utils/web_meta_utils_stub.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/sales_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminPackageStickerView extends StatefulWidget {
  final String businessSlug;
  final String saleId;

  const AdminPackageStickerView({
    super.key,
    required this.businessSlug,
    required this.saleId,
  });

  @override
  State<AdminPackageStickerView> createState() =>
      _AdminPackageStickerViewState();
}

class _AdminPackageStickerViewState extends State<AdminPackageStickerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().loadSales(widget.businessSlug);
      context.read<BusinessProvider>().loadBusiness(widget.businessSlug);
    });
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
          backgroundColor: AdminTheme.sidebarBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.white.withValues(alpha: 0.08), height: 1.0),
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

    final paymentLabels = {
      "efectivo": "Efectivo",
      "tarjeta": "Tarjeta",
      "yape": "Yape",
      "plin": "Plin",
      "transferencia": "Transferencia",
      "contraentrega": "Pago contra entrega",
      "deposito_interbancario": "Depósito interbancario",
    };

    final paymentMethodLabel =
        paymentLabels[sale.paymentMethod] ?? sale.paymentMethod;

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.sidebarBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Sticker de empaque ${sale.number}",
          style: AdminTheme.appBarTitle(),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => printPackageSticker(sale!, business),
            icon: const Icon(Icons.print_rounded, size: 18),
            style: AdminTheme.primaryButton(),
            label: Text(
              "Imprimir Sticker",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white.withValues(alpha: 0.08), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF0F172A), width: 4),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                letterSpacing: -0.5,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            business.slug.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "N°",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          sale.number,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 2, color: const Color(0xFF0F172A)),
                const SizedBox(height: 16),
                _sectionLabel("Enviar a"),
                Text(
                  sale.customerName,
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                ),
                if (sale.customerDoc.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    "DOC: ${sale.customerDoc}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _sectionLabel("Dirección"),
                Text(
                  sale.customerAddress.isEmpty ? "—" : sale.customerAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionLabel("Teléfono"),
                Text(
                  sale.customerPhone.isEmpty ? "—" : sale.customerPhone,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF0F172A), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "MÉTODO DE PAGO",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        paymentMethodLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("Contenido"),
                      const SizedBox(height: 4),
                      ...sale.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            "• ${item.quantity.toStringAsFixed(0)} x ${item.productName}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF334155),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF0F172A), width: 2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        business.address ?? '',
                        style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "WhatsApp: ${business.whatsappNumber}",
                        style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
