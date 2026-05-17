import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';

abstract class UbigeoDatasource {
  Future<List<Ubigeo>> getDepartamentos();
  Future<List<Ubigeo>> getProvincias(String departamentoId);
  Future<List<Ubigeo>> getDistritos(String provinciaId);
}
