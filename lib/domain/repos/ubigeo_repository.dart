import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';

abstract class UbigeoRepository {
  Future<List<Ubigeo>> getDepartamentos();
  Future<List<Ubigeo>> getProvincias(String departamentoId);
  Future<List<Ubigeo>> getDistritos(String provinciaId);
}
