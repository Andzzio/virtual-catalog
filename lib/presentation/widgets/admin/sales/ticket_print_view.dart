import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/utils/number_to_words.dart';
import 'package:virtual_catalog_app/config/utils/web_meta_utils.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class TicketPrintView extends StatelessWidget {
  final Sale sale;
  const TicketPrintView({super.key, required this.sale});

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
    final businessProvider = context.watch<BusinessProvider>();
    final business = businessProvider.business ??
        Business(
          slug: '',
          ownerId: '',
          name: 'Comercio',
          description: '',
          logoUrl: '',
          whatsappNumber: '',
          banners: [],
          deliveryMethods: [],
          paymentMethods: [],
        );

    final dateStr =
        "${sale.createdAt.day.toString().padLeft(2, '0')}/${sale.createdAt.month.toString().padLeft(2, '0')}/${sale.createdAt.year}";
    final timeStr =
        "${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}";
    final docTypeNum = sale.documentType == 'factura' ? '01' : sale.documentType == 'boleta' ? '03' : sale.documentType == 'nota_credito' ? '07' : sale.documentType == 'nota_debito' ? '08' : '03';
    final numberParts = sale.number.split('-');
    final series = numberParts.isNotEmpty ? numberParts[0] : '';
    final correlative = numberParts.length > 1 ? numberParts[1] : '';

    final showQr = sale.documentType != 'nota_venta';
    final qrData = showQr
        ? "${business.ruc ?? ''}|$docTypeNum|$series|$correlative|${sale.igv.toStringAsFixed(2)}|${sale.total.toStringAsFixed(2)}|$dateStr|${sale.customerDoc.length == 11 ? '6' : '1'}|${sale.customerDoc}|"
        : "";
    final qrUrl = showQr
        ? "https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=${Uri.encodeComponent(qrData)}"
        : null;
    final amountInWords = numberToWords(sale.total);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminTheme.radiusLg)),
      backgroundColor: AdminTheme.cardBg,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vista Previa de Impresión',
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AdminTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
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
                          sale.documentType == 'nota_venta'
                              ? 'NOTA DE VENTA'
                              : sale.documentType == 'factura'
                                  ? 'FACTURA ELECTRÓNICA'
                                  : sale.documentType == 'nota_credito'
                                      ? 'NOTA DE CRÉDITO ELECTRÓNICA'
                                      : sale.documentType == 'nota_debito'
                                          ? 'NOTA DE DÉBITO ELECTRÓNICA'
                                          : 'BOLETA DE VENTA ELECTRÓNICA',
                          style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ),
                      Center(
                        child: Text(
                          'NRO: ${sale.number}',
                          style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ),
                      if (sale.documentType == 'nota_credito' || sale.documentType == 'nota_debito')
                        if (sale.refDocSerie != null && sale.refDocSerie!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Center(
                              child: Text(
                                'Doc. que modifica: ${sale.refDocSerie}-${sale.refDocNumero?.toString().padLeft(8, '0') ?? ''}',
                                style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, color: Colors.black54)),
                              ),
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
                          if (sale.documentType != 'nota_venta' || sale.customerDoc.isNotEmpty)
                            TableRow(
                              children: [
                                Text(
                                  sale.documentType == 'nota_venta'
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
                      if (sale.documentType != 'nota_venta') ...[
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
                      Text(
                        amountInWords,
                        style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                      if ((sale.documentType == 'nota_credito' || sale.documentType == 'nota_debito') && sale.motivoDescripcion != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Motivo:', style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
                            Text(sale.motivoDescripcion!, style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 10, color: Colors.black))),
                          ],
                        ),
                      ],
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
                          sale.documentType == 'nota_venta'
                              ? 'Representación física de una Nota de Venta de uso interno.'
                              : sale.documentType == 'nota_credito'
                                  ? 'Representación impresa de la Nota de Crédito Electrónica.'
                                  : sale.documentType == 'nota_debito'
                                      ? 'Representación impresa de la Nota de Débito Electrónica.'
                                      : 'Representación impresa de la ${sale.documentType == 'factura' ? 'Factura' : 'Boleta'} Electrónica.',
                          style: GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 9, color: Colors.black54)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (sale.documentType == 'nota_venta')
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
                        ),
                      ),
                      if (sale.documentType != 'nota_venta') ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Image.network(
                            qrUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                      if (sale.sunatHash != null && sale.sunatHash!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDashedLine(),
                        const SizedBox(height: 4),
                        Text(
                          'Hash: ${sale.sunatHash}',
                          style: GoogleFonts.courierPrime(
                            textStyle: const TextStyle(fontSize: 7, color: Colors.black54),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (sale.pdfUrl != null && sale.pdfUrl!.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(sale.pdfUrl!)),
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      style: AdminTheme.outlinedButton(),
                      label: Text('Ver PDF', style: GoogleFonts.getFont(FontNames.fontNameH2)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: AdminTheme.outlinedButton(),
                    child: Text('Cerrar', style: GoogleFonts.getFont(FontNames.fontNameH2)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      printSaleTicket(sale, business);
                    },
                    icon: const Icon(Icons.print, size: 18),
                    style: AdminTheme.primaryButton(),
                    label: Text('Imprimir', style: GoogleFonts.getFont(FontNames.fontNameH2)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
