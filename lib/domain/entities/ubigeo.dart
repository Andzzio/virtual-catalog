class Ubigeo {
  final String idUbigeo;
  final String nombre;
  final String codigo;
  final String etiqueta;
  final int nivel;
  final String idPadre;
  final int numeroHijos;

  Ubigeo({
    required this.idUbigeo,
    required this.nombre,
    required this.codigo,
    required this.etiqueta,
    required this.nivel,
    required this.idPadre,
    this.numeroHijos = 0,
  });
}
