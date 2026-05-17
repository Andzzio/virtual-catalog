import 'package:virtual_catalog_app/domain/datasources/ubigeo_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';
import 'package:virtual_catalog_app/domain/repos/ubigeo_repository.dart';

class UbigeoRepositoryImpl implements UbigeoRepository {
  final UbigeoDatasource datasource;

  UbigeoRepositoryImpl({required this.datasource});

  @override
  Future<List<Ubigeo>> getDepartamentos() {
    return datasource.getDepartamentos();
  }

  @override
  Future<List<Ubigeo>> getProvincias(String departamentoId) {
    return datasource.getProvincias(departamentoId);
  }

  @override
  Future<List<Ubigeo>> getDistritos(String provinciaId) {
    return datasource.getDistritos(provinciaId);
  }
}
