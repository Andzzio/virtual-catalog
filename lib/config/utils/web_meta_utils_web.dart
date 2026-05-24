import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:virtual_catalog_app/domain/entities/sale.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/config/utils/number_to_words.dart';

void updatePageTitle(String title) {
  web.document.title = title;
}

void updateFavicon(String iconUrl) {
  if (iconUrl.isEmpty) return;

  final link = web.document.getElementById('favicon');
  if (link != null) {
    link.setAttribute('href', iconUrl);
  }
}

void printSaleTicket(Sale sale, Business business) {
  final printWindow = web.window.open('', '_blank');
  if (printWindow == null) return;

  final dateStr = "${sale.createdAt.day.toString().padLeft(2, '0')}/${sale.createdAt.month.toString().padLeft(2, '0')}/${sale.createdAt.year}";
  final timeStr = "${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}";
  final docTypeNum = sale.documentType == 'factura' ? '01' : '03';
  final numberParts = sale.number.split('-');
  final series = numberParts.isNotEmpty ? numberParts[0] : '';
  final correlative = numberParts.length > 1 ? numberParts[1] : '';
  
  final qrData = "${business.ruc ?? ''}|$docTypeNum|$series|$correlative|${sale.igv.toStringAsFixed(2)}|${sale.total.toStringAsFixed(2)}|$dateStr|${sale.customerDoc.length == 11 ? '6' : '1'}|${sale.customerDoc}|";
  final qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=${Uri.encodeComponent(qrData)}";
  final amountInWords = numberToWords(sale.total);

  final itemsHtml = sale.items.map((item) => '''
    <tr>
      <td style="padding: 4px 0;">
        ${item.productName}${item.variantName.isNotEmpty ? ' (${item.variantName})' : ''}
      </td>
      <td style="text-align: center; padding: 4px 0; vertical-align: top;">
        ${item.quantity.toStringAsFixed(1)}
      </td>
      <td style="text-align: right; padding: 4px 0; vertical-align: top;">
        ${item.unitPrice.toStringAsFixed(2)}
      </td>
      <td style="text-align: right; padding: 4px 0; vertical-align: top;">
        ${item.lineTotal.toStringAsFixed(2)}
      </td>
    </tr>
  ''').join('');

  final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <title>Ticket ${sale.number}</title>
      <style>
        @page {
          size: 80mm auto;
          margin: 0;
        }
        body {
          font-family: 'Courier New', Courier, monospace;
          font-size: 11px;
          line-height: 1.3;
          width: 80mm;
          margin: 0;
          padding: 8px;
          color: #000;
          background-color: #fff;
        }
        .text-center {
          text-align: center;
        }
        .text-right {
          text-align: right;
        }
        .bold {
          font-weight: bold;
        }
        .divider {
          border-top: 1px dashed #000;
          margin: 8px 0;
        }
        .double-divider {
          border-top: 1px double #000;
          margin: 8px 0;
        }
        table {
          width: 100%;
          border-collapse: collapse;
        }
        .items-table th {
          border-bottom: 1px dashed #000;
          padding-bottom: 4px;
          font-size: 11px;
        }
        .totals-table td {
          padding: 2px 0;
        }
        .totals-table tr.total-row td {
          font-weight: bold;
          font-size: 12px;
        }
        @media print {
          body {
            width: 80mm;
          }
        }
      </style>
    </head>
    <body>
      <div class="text-center">
        <h2 style="margin: 0 0 4px 0; font-size: 14px;">${business.name.toUpperCase()}</h2>
        ${business.ruc != null ? '<div class="bold">R.U.C. ${business.ruc}</div>' : ''}
        ${business.address != null ? '<div>${business.address}</div>' : ''}
        <div>WhatsApp: ${business.whatsappNumber}</div>
      </div>
      
      <div class="divider"></div>
      
      <div class="text-center" style="margin: 5px 0;">
        <div class="bold" style="font-size: 12px;">${sale.documentType == 'nota_venta' ? 'NOTA DE VENTA' : sale.documentType == 'factura' ? 'FACTURA ELECTRÓNICA' : 'BOLETA DE VENTA ELECTRÓNICA'}</div>
        <div class="bold" style="font-size: 12px;">NRO: ${sale.number}</div>
      </div>
      
      <div class="divider"></div>
      
      <div>
        <table style="font-size: 11px;">
          <tr>
            <td style="width: 30%; font-weight: bold; vertical-align: top;">Señores:</td>
            <td>${sale.customerName}</td>
          </tr>
          ${(sale.documentType != 'nota_venta' || sale.customerDoc.isNotEmpty) ? '<tr><td style="font-weight: bold; vertical-align: top;">${sale.documentType == 'factura' ? 'R.U.C.:' : sale.documentType == 'boleta' ? 'D.N.I.:' : 'DOC. IDENTIDAD:'}</td><td>${sale.customerDoc}</td></tr>' : ''}
          ${sale.customerAddress.isNotEmpty ? '<tr><td style="font-weight: bold; vertical-align: top;">Dirección:</td><td>${sale.customerAddress}</td></tr>' : ''}
          <tr>
            <td style="font-weight: bold; vertical-align: top;">F. Emisión:</td>
            <td>$dateStr $timeStr</td>
          </tr>
          <tr>
            <td style="font-weight: bold; vertical-align: top;">Pago:</td>
            <td>${sale.paymentMethod.toUpperCase()}</td>
          </tr>
        </table>
      </div>
      
      <div class="divider"></div>
      
      <table class="items-table" style="font-size: 11px;">
        <thead>
          <tr>
            <th style="text-align: left; width: 50%;">Producto</th>
            <th style="text-align: center; width: 12%;">Cant</th>
            <th style="text-align: right; width: 18%;">Precio</th>
            <th style="text-align: right; width: 20%;">Total</th>
          </tr>
        </thead>
        <tbody>
          $itemsHtml
        </tbody>
      </table>
      
      <div class="divider"></div>
      
      <table class="totals-table" style="font-size: 11px;">
        ${sale.documentType != 'nota_venta' ? '<tr><td>OP. GRAVADA</td><td class="text-right">S/ ${sale.subtotal.toStringAsFixed(2)}</td></tr><tr><td>I.G.V. (18%)</td><td class="text-right">S/ ${sale.igv.toStringAsFixed(2)}</td></tr>' : ''}
        <tr class="total-row">
          <td>TOTAL VENTA</td>
          <td class="text-right">S/ ${sale.total.toStringAsFixed(2)}</td>
        </tr>
      </table>
      
      <div style="margin: 8px 0; font-size: 10px; font-weight: bold;">
        $amountInWords
      </div>
      
      ${sale.notes.isNotEmpty ? '<div class="divider"></div><div style="font-size: 10px;"><strong>Notas:</strong><br>${sale.notes}</div>' : ''}
      
      <div class="divider"></div>
      
      <div class="text-center" style="font-size: 10px; margin-top: 10px;">
        <div>VENDEDOR(A): ${sale.userName.toUpperCase()}</div>
        <div style="margin: 5px 0;">${sale.documentType == 'nota_venta' ? 'Representación física de una Nota de Venta de uso interno.' : 'Representación impresa de la ${sale.documentType == 'factura' ? 'Factura' : 'Boleta'} Electrónica.'}</div>
        ${sale.documentType == 'nota_venta' ? '<div style="margin: 3px 0;">Sin valor tributario.</div>' : ''}
        <div style="margin: 5px 0;">Gracias por su preferencia.</div>
        ${sale.documentType != 'nota_venta' ? '<div style="margin-top: 12px;"><img src="$qrUrl" width="120" height="120" style="display: block; margin: 0 auto;" /></div>' : ''}
        ${sale.sunatHash != null && sale.sunatHash!.isNotEmpty ? '<div class="divider"></div><div style="font-size: 7px; color: #888; text-align: center;">Hash: ${sale.sunatHash}</div>' : ''}
      </div>
    </body>
    </html>
  ''';

  printWindow.document.open();
  printWindow.document.write(htmlContent.toJS);
  printWindow.document.close();
}
