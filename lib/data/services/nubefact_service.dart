import 'package:dio/dio.dart';

class NubefactResponse {
  final bool accepted;
  final String? description;
  final String? hash;
  final String? pdfUrl;
  final String? xmlUrl;
  final String? cdrUrl;
  final String? serie;
  final int? numero;

  NubefactResponse({
    required this.accepted,
    this.description,
    this.hash,
    this.pdfUrl,
    this.xmlUrl,
    this.cdrUrl,
    this.serie,
    this.numero,
  });
}

class NubefactService {
  final Dio _dio = Dio();

  Future<NubefactResponse> emitInvoice({
    required String url,
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data;

      if (data == null) {
        return NubefactResponse(
          accepted: false,
          description: 'Respuesta vacía del servidor de facturación',
        );
      }

      final bool isAccepted = data['aceptada_por_sunat'] == true;

      return NubefactResponse(
        accepted: isAccepted,
        description: data['sunat_description']?.toString() ??
            data['errors']?.toString() ??
            (isAccepted ? 'Aceptado por SUNAT' : 'Rechazado por SUNAT'),
        hash: data['cadena_para_codigo_qr']?.toString() ?? data['hash']?.toString(),
        pdfUrl: data['enlace_del_pdf']?.toString(),
        xmlUrl: data['enlace_del_xml']?.toString(),
        cdrUrl: data['enlace_del_cdr']?.toString(),
        serie: data['serie']?.toString(),
        numero: data['numero'] is int ? data['numero'] : int.tryParse(data['numero']?.toString() ?? ''),
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMsg = 'Error de conexión con Nubefact';

      if (errorData is Map) {
        errorMsg = errorData['errors']?.toString() ??
            errorData['message']?.toString() ??
            errorMsg;
      } else if (errorData is String) {
        errorMsg = errorData;
      }

      return NubefactResponse(
        accepted: false,
        description: errorMsg,
      );
    }
  }

  Map<String, dynamic> buildInvoicePayload({
    required String documentType,
    required String serie,
    required int correlativo,
    required String customerDocType,
    required String customerDoc,
    required String customerName,
    required String customerAddress,
    required DateTime emissionDate,
    required double subtotal,
    required double igv,
    required double total,
    required List<Map<String, dynamic>> items,
  }) {
    final tipoComprobante = documentType == 'factura' ? 1 : 2;

    return {
      'operacion': 'generar_comprobante',
      'tipo_de_comprobante': tipoComprobante,
      'serie': serie,
      'numero': correlativo,
      'sunat_transaction': 1,
      'cliente_tipo_de_documento': customerDocType,
      'cliente_numero_de_documento': customerDoc,
      'cliente_denominacion': customerName,
      'cliente_direccion': customerAddress.isEmpty ? '-' : customerAddress,
      'fecha_de_emision': '${emissionDate.day.toString().padLeft(2, '0')}-${emissionDate.month.toString().padLeft(2, '0')}-${emissionDate.year}',
      'moneda': 1,
      'porcentaje_de_igv': 18.00,
      'total_gravada': subtotal,
      'total_igv': igv,
      'total': total,
      'enviar_automaticamente_a_la_sunat': true,
      'enviar_automaticamente_al_cliente': false,
      'items': items,
    };
  }

  Map<String, dynamic> buildItemPayload({
    required String description,
    required int quantity,
    required double unitPrice,
    required double igvAmount,
    required double lineTotal,
  }) {
    final valorUnitario = double.parse((unitPrice / 1.18).toStringAsFixed(2));
    final subtotalItem = double.parse((valorUnitario * quantity).toStringAsFixed(2));

    return {
      'unidad_de_medida': 'NIU',
      'codigo': '',
      'descripcion': description,
      'cantidad': quantity,
      'valor_unitario': valorUnitario,
      'precio_unitario': unitPrice,
      'subtotal': subtotalItem,
      'tipo_de_igv': 1,
      'igv': igvAmount,
      'total': lineTotal,
      'anticipo_regularizacion': false,
    };
  }
}
