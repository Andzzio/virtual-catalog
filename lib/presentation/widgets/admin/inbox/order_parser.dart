class OrderParser {
  static Map<String, dynamic> parse(String content) {
    final data = <String, dynamic>{};

    final nameMatch = RegExp(r'-\s*Nombre:\s*(.*)').firstMatch(content);
    if (nameMatch != null) {
      data['name'] = nameMatch.group(1)?.trim() ?? '';
    }

    final dniMatch = RegExp(r'-\s*DNI:\s*(\d*)').firstMatch(content);
    if (dniMatch != null) {
      data['dni'] = dniMatch.group(1)?.trim() ?? '';
    }

    final phoneMatch = RegExp(r'-\s*Teléfono:\s*(\d*)').firstMatch(content);
    if (phoneMatch != null) {
      data['phone'] = phoneMatch.group(1)?.trim() ?? '';
    }

    final addressMatch = RegExp(r'-\s*Dirección:\s*(.*)').firstMatch(content);
    final depMatch = RegExp(r'-\s*Departamento:\s*(.*)').firstMatch(content);
    final provMatch = RegExp(r'-\s*Provincia:\s*(.*)').firstMatch(content);
    final distMatch = RegExp(r'-\s*Distrito:\s*(.*)').firstMatch(content);

    var address = '';
    if (addressMatch != null) {
      address += addressMatch.group(1)?.trim() ?? '';
    }
    final details = <String>[];
    if (distMatch != null && distMatch.group(1)!.trim().isNotEmpty) {
      details.add(distMatch.group(1)!.trim());
    }
    if (provMatch != null && provMatch.group(1)!.trim().isNotEmpty) {
      details.add(provMatch.group(1)!.trim());
    }
    if (depMatch != null && depMatch.group(1)!.trim().isNotEmpty) {
      details.add(depMatch.group(1)!.trim());
    }
    if (details.isNotEmpty) {
      address += ' (${details.join(", ")})';
    }
    data['address'] = address.trim();

    final notesMatch = RegExp(r'-\s*Notas:\s*(.*)|📝\s*Notas:\s*(.*)').firstMatch(content);
    if (notesMatch != null) {
      data['notes'] =
          (notesMatch.group(1) ?? notesMatch.group(2))?.trim() ?? '';
    }

    final paymentMatch = RegExp(r'Método de pago:\s*(.*)').firstMatch(content);
    if (paymentMatch != null) {
      data['paymentMethod'] = paymentMatch.group(1)?.trim() ?? '';
    }

    final lines = content.split('\n');
    final items = <Map<String, dynamic>>[];
    var inProducts = false;
    for (final line in lines) {
      if (line.contains('📦 *Productos:*')) {
        inProducts = true;
        continue;
      }
      if (line.contains('💰 *Resumen:*') || line.contains('💳 Método de pago:')) {
        inProducts = false;
      }
      if (inProducts) {
        final productMatch = RegExp(
          r'^\d+\.\s*(.+?)\s*-\s*(.+?),\s*(.+?)\s*x\s*(\d+)\s*->\s*S/\.\s*([\d\.]+)',
        ).firstMatch(line.trim());
        if (productMatch != null) {
          final productName = productMatch.group(1)?.trim() ?? '';
          final variantName = productMatch.group(2)?.trim() ?? '';
          final size = productMatch.group(3)?.trim() ?? '';
          final quantity = int.tryParse(productMatch.group(4) ?? '1') ?? 1;
          final price = double.tryParse(productMatch.group(5) ?? '0.0') ?? 0.0;

          items.add({
            'productName': productName,
            'variantName': '$variantName, $size',
            'quantity': quantity,
            'unitPrice': quantity > 0 ? (price / quantity) : price,
          });
        }
      }
    }
    data['items'] = items;

    return data;
  }
}
