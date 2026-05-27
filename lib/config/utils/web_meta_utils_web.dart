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

void printSaleInvoice(Sale sale, Business business) {
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
    <tr style="border-bottom: 1px solid #e2e8f0;">
      <td style="padding: 10px 8px; font-family: monospace;">${item.quantity.toStringAsFixed(1)}</td>
      <td style="padding: 10px 8px;">
        <div style="font-weight: bold; color: #1e293b;">${item.productName}</div>
        ${item.variantName.isNotEmpty ? '<div style="font-size: 10px; color: #64748b;">${item.variantName}</div>' : ''}
      </td>
      <td style="padding: 10px 8px; text-align: right; font-family: monospace;">${item.unitPrice.toStringAsFixed(2)}</td>
      <td style="padding: 10px 8px; text-align: right; font-family: monospace; font-weight: bold;">${item.lineTotal.toStringAsFixed(2)}</td>
    </tr>
  ''').join('');

  final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <title>Comprobante ${sale.number}</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          font-size: 13px;
          line-height: 1.5;
          margin: 0;
          padding: 20px;
          color: #334155;
          background-color: #fff;
        }
        .container {
          max-width: 800px;
          margin: 0 auto;
          border: 1px solid #cbd5e1;
          padding: 40px;
        }
        .header {
          display: flex;
          justify-content: space-between;
          border-bottom: 2px solid #0f172a;
          padding-bottom: 20px;
        }
        .header-left {
          flex: 1;
        }
        .header-right {
          border: 2px solid #0f172a;
          padding: 15px 25px;
          text-align: center;
          min-width: 220px;
        }
        .details-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 20px;
          margin-top: 20px;
          padding-bottom: 20px;
          border-bottom: 1px solid #cbd5e1;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin-top: 20px;
        }
        th {
          background-color: #f1f5f9;
          text-align: left;
          padding: 8px;
          font-size: 11px;
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }
        .totals-container {
          display: flex;
          justify-content: flex-end;
          margin-top: 20px;
        }
        .totals-box {
          width: 250px;
        }
        .totals-row {
          display: flex;
          justify-content: space-between;
          padding: 4px 0;
        }
        .totals-row.grand-total {
          border-top: 2px solid #0f172a;
          font-size: 16px;
          font-weight: bold;
          padding-top: 8px;
          margin-top: 8px;
        }
        @media print {
          body { padding: 0; }
          .container { border: none; padding: 0; }
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div class="header-left">
            <h1 style="margin: 0; font-size: 22px; font-weight: 900; color: #0f172a;">${business.name.toUpperCase()}</h1>
            <div style="margin-top: 5px; color: #475569;">${business.address ?? ''}</div>
            <div style="color: #475569;">WhatsApp: ${business.whatsappNumber}</div>
            ${business.ruc != null ? '<div style="font-family: monospace; margin-top: 8px; font-weight: bold;">RUC: ${business.ruc}</div>' : ''}
          </div>
          <div class="header-right">
            <div style="font-size: 14px; font-weight: bold; color: #0f172a; letter-spacing: 1px;">
              ${sale.documentType == 'factura' ? 'FACTURA ELECTRÓNICA' : 'BOLETA DE VENTA'}
            </div>
            <div style="font-size: 20px; font-weight: bold; font-family: monospace; margin-top: 5px;">${sale.number}</div>
          </div>
        </div>

        <div class="details-grid">
          <div>
            <div style="font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; font-weight: bold;">Cliente</div>
            <div style="font-size: 15px; font-weight: bold; margin-top: 4px; color: #0f172a;">${sale.customerName}</div>
            ${sale.customerDoc.isNotEmpty ? '<div style="font-family: monospace; font-size: 12px; margin-top: 4px;">${sale.documentType == 'factura' ? 'RUC' : 'DNI'}: ${sale.customerDoc}</div>' : ''}
            ${sale.customerAddress.isNotEmpty ? '<div style="color: #475569; margin-top: 4px;">${sale.customerAddress}</div>' : ''}
          </div>
          <div style="text-align: right;">
            <div style="font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; font-weight: bold;">Detalles de Emisión</div>
            <div style="margin-top: 4px;">Fecha: $dateStr</div>
            <div>Hora: $timeStr</div>
            <div style="font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; font-weight: bold; margin-top: 12px;">Método de Pago</div>
            <div style="margin-top: 4px; font-weight: bold; text-transform: capitalize;">${sale.paymentMethod}</div>
          </div>
        </div>

        <table>
          <thead>
            <tr>
              <th style="width: 10%;">Cant.</th>
              <th style="width: 55%;">Descripción</th>
              <th style="width: 15%; text-align: right;">P. Unit.</th>
              <th style="width: 20%; text-align: right;">Total</th>
            </tr>
          </thead>
          <tbody>
            $itemsHtml
          </tbody>
        </table>

        <div class="totals-container">
          <div class="totals-box">
            ${sale.documentType != 'nota_venta' ? '''
              <div class="totals-row"><span>Op. Gravadas</span><span style="font-family: monospace;">S/ ${sale.subtotal.toStringAsFixed(2)}</span></div>
              <div class="totals-row"><span>IGV 18%</span><span style="font-family: monospace;">S/ ${sale.igv.toStringAsFixed(2)}</span></div>
            ''' : ''}
            <div class="totals-row grand-total">
              <span>TOTAL S/</span>
              <span style="font-family: monospace;">${sale.total.toStringAsFixed(2)}</span>
            </div>
          </div>
        </div>

        <div style="margin-top: 10px; font-weight: bold; font-size: 11px;">
          SON: $amountInWords
        </div>

        ${sale.notes.isNotEmpty ? '''
          <div style="margin-top: 30px; border-top: 1px solid #cbd5e1; padding-top: 15px;">
            <div style="font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; font-weight: bold; mb: 4px;">Observaciones</div>
            <div style="color: #475569;">${sale.notes}</div>
          </div>
        ''' : ''}

        <div style="margin-top: 50px; text-align: center; font-size: 11px; color: #64748b; border-top: 1px solid #cbd5e1; padding-top: 20px;">
          Representación impresa del comprobante electrónico · Emitido por CRM
          ${sale.documentType != 'nota_venta' ? '<div style="margin-top: 15px;"><img src="$qrUrl" width="120" height="120" /></div>' : ''}
        </div>
      </div>
    </body>
    </html>
  ''';

  printWindow.document.open();
  printWindow.document.write(htmlContent.toJS);
  printWindow.document.close();
}

void printPackageSticker(Sale sale, Business business) {
  final printWindow = web.window.open('', '_blank');
  if (printWindow == null) return;

  final paymentLabels = {
    "efectivo": "Efectivo",
    "tarjeta": "Tarjeta",
    "yape": "Yape",
    "plin": "Plin",
    "transferencia": "Transferencia",
    "contraentrega": "Pago contra entrega",
    "deposito_interbancario": "Depósito interbancario",
  };

  final paymentMethodLabel = paymentLabels[sale.paymentMethod] ?? sale.paymentMethod;

  final itemsHtml = sale.items.map((item) => '''
    <div>• ${item.quantity.toStringAsFixed(0)} x ${item.productName}</div>
  ''').join('');

  final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <title>Sticker ${sale.number}</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 0;
          padding: 0;
          display: flex;
          justify-content: center;
          background-color: #fff;
        }
        .sticker-card {
          width: 100mm;
          height: 150mm;
          box-sizing: border-box;
          border: 4px solid #0f172a;
          padding: 20px;
          display: flex;
          flex-direction: column;
        }
        .sticker-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          border-bottom: 2px solid #0f172a;
          padding-bottom: 8px;
        }
        .label-caps {
          font-size: 10px;
          text-transform: uppercase;
          letter-spacing: 1.5px;
          color: #64748b;
          font-weight: bold;
          margin-top: 15px;
        }
        .customer-name {
          font-size: 20px;
          font-weight: 900;
          color: #0f172a;
          line-height: 1.2;
          margin-top: 4px;
        }
        .info-value {
          font-size: 14px;
          font-weight: bold;
          margin-top: 4px;
          color: #1e293b;
        }
        .payment-box {
          border: 2px solid #0f172a;
          padding: 8px;
          margin-top: 15px;
        }
        .items-box {
          border-top: 1px solid #cbd5e1;
          margin-top: auto;
          padding-top: 10px;
          font-size: 11px;
          line-height: 1.4;
        }
        @media print {
          body { display: block; }
          .sticker-card { width: 100mm; height: 150mm; border: 4px solid #000; }
        }
      </style>
    </head>
    <body>
      <div class="sticker-card">
        <div class="sticker-header">
          <div>
            <div style="font-size: 22px; font-weight: 900; text-transform: uppercase; letter-spacing: -0.5px;">${business.name.toUpperCase()}</div>
            <div style="font-size: 9px; letter-spacing: 2px; text-transform: uppercase; color: #64748b;">${business.slug}</div>
          </div>
          <div style="text-align: right;">
            <div style="font-size: 9px; text-transform: uppercase; color: #64748b;">N°</div>
            <div style="font-family: monospace; font-size: 13px; font-weight: bold;">${sale.number}</div>
          </div>
        </div>

        <div class="label-caps">Enviar a</div>
        <div class="customer-name">${sale.customerName}</div>
        ${sale.customerDoc.isNotEmpty ? '<div style="font-family: monospace; font-size: 11px; color: #64748b; margin-top: 2px;">DOC: ${sale.customerDoc}</div>' : ''}

        <div class="label-caps">Dirección</div>
        <div class="info-value">${sale.customerAddress.isEmpty ? '—' : sale.customerAddress}</div>

        <div class="label-caps">Teléfono</div>
        <div class="info-value" style="font-family: monospace; font-size: 15px;">${sale.customerPhone.isEmpty ? '—' : sale.customerPhone}</div>

        <div class="payment-box">
          <div style="font-size: 9px; text-transform: uppercase; letter-spacing: 1px; color: #475569; font-weight: bold;">Método de Pago</div>
          <div style="font-size: 16px; font-weight: 900; margin-top: 2px; text-transform: uppercase;">$paymentMethodLabel</div>
        </div>

        <div class="items-box">
          <div style="font-size: 9px; text-transform: uppercase; letter-spacing: 1px; color: #64748b; font-weight: bold; margin-bottom: 4px;">Contenido</div>
          $itemsHtml
        </div>

        <div style="margin-top: 15px; border-top: 2px solid #0f172a; padding-top: 8px; text-align: center; font-size: 9px; color: #64748b;">
          <div>${business.address ?? ''}</div>
          <div>WhatsApp: ${business.whatsappNumber}</div>
        </div>
      </div>
    </body>
    </html>
  ''';

  printWindow.document.open();
  printWindow.document.write(htmlContent.toJS);
  printWindow.document.close();
}

void printStickers(List<Map<String, dynamic>> items, Business business) {
  final printWindow = web.window.open('', '_blank');
  if (printWindow == null) return;

  final stickersHtml = items.map((item) {
    final name = item["name"] ?? "";
    final sku = item["sku"] ?? "";
    final price = double.tryParse(item["price"].toString()) ?? 0.0;
    final size = item["size"];
    final color = item["color"];
    final description = item["description"] ?? "";

    return '''
      <div class="sticker-card">
        <div class="business-name">${business.name.toUpperCase()}</div>
        <div class="product-name">$name</div>
        <div class="product-desc">${description.isEmpty ? '—' : description}</div>
        <div class="variant-details">
          ${size != null && size.toString().isNotEmpty ? '<span><b>Talla:</b> $size</span>' : ''}
          ${color != null && color.toString().isNotEmpty ? '<span><b>Color:</b> $color</span>' : ''}
        </div>
        <div class="price">S/ ${price.toStringAsFixed(2)}</div>
        <div class="barcode-container">
          <svg class="barcode" data-value="$sku"></svg>
        </div>
      </div>
    ''';
  }).join('');

  final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <title>Imprimir Etiquetas</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 0;
          padding: 0;
          background-color: #fff;
        }
        .print-grid {
          display: grid;
          grid-template-columns: repeat(3, 150px);
          gap: 10px;
          padding: 10px;
          justify-content: center;
        }
        .sticker-card {
          width: 150px;
          height: 115px;
          box-sizing: border-box;
          border: 2px solid #000;
          padding: 6px;
          background-color: #fff;
          text-align: center;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          overflow: hidden;
        }
        .business-name {
          font-size: 8px;
          font-weight: 900;
          text-transform: uppercase;
          letter-spacing: 0.5px;
          margin: 0;
        }
        .product-name {
          font-size: 9px;
          font-weight: bold;
          line-height: 1.1;
          margin: 2px 0 0 0;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
          overflow: hidden;
        }
        .product-desc {
          font-size: 7px;
          color: #555;
          margin: 0;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        .variant-details {
          display: flex;
          justify-content: space-between;
          font-size: 7px;
          margin: 1px 0;
          padding: 0 4px;
        }
        .price {
          font-size: 11px;
          font-weight: 900;
          margin: 1px 0;
        }
        .barcode-container {
          display: flex;
          justify-content: center;
          align-items: center;
          height: 38px;
        }
        .barcode {
          max-width: 100%;
          max-height: 100%;
        }
        @media print {
          body {
            padding: 0;
          }
          .print-grid {
            padding: 0;
            gap: 8px;
          }
        }
      </style>
      <script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.5/dist/JsBarcode.all.min.js"></script>
    </head>
    <body>
      <div class="print-grid">
        $stickersHtml
      </div>
      <script>
        window.onload = function() {
          var barcodes = document.querySelectorAll('.barcode');
          barcodes.forEach(function(el) {
            var val = el.getAttribute('data-value');
            if (val) {
              try {
                JsBarcode(el, val, {
                  format: "CODE128",
                  width: 1.2,
                  height: 30,
                  displayValue: true,
                  fontSize: 10,
                  margin: 0
                });
              } catch(e) {}
            }
          });
          setTimeout(function() {
            window.print();
          }, 500);
        }
      </script>
    </body>
    </html>
  ''';

  printWindow.document.open();
  printWindow.document.write(htmlContent.toJS);
  printWindow.document.close();
}
