import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';

class UbigeoModel {
  final String idUbigeo;
  final String nombre;
  final String codigo;
  final String etiqueta;
  final int nivel;
  final String idPadre;
  final int numeroHijos;

  UbigeoModel({
    required this.idUbigeo,
    required this.nombre,
    required this.codigo,
    required this.etiqueta,
    required this.nivel,
    required this.idPadre,
    this.numeroHijos = 0,
  });

  factory UbigeoModel.fromJson(Map<String, dynamic> json) {
    return UbigeoModel(
      idUbigeo: json['id_ubigeo'] ?? '',
      nombre: json['nombre_ubigeo'] ?? '',
      codigo: json['codigo_ubigeo'] ?? '',
      etiqueta: json['etiqueta_ubigeo'] ?? '',
      nivel: int.tryParse(json['nivel_ubigeo']?.toString() ?? '0') ?? 0,
      idPadre: json['id_padre_ubigeo'] ?? '',
      numeroHijos: int.tryParse(json['numero_hijos_ubigeo']?.toString() ?? '0') ?? 0,
    );
  }

  Ubigeo toEntity() {
    return Ubigeo(
      idUbigeo: idUbigeo,
      nombre: nombre,
      codigo: codigo,
      etiqueta: etiqueta,
      nivel: nivel,
      idPadre: idPadre,
      numeroHijos: numeroHijos,
    );
  }
}
