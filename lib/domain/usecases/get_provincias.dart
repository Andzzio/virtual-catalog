import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';
import 'package:virtual_catalog_app/domain/repos/ubigeo_repository.dart';

class GetProvincias {
  final UbigeoRepository repository;

  GetProvincias(this.repository);

  Future<List<Ubigeo>> call(String departamentoId) {
    return repository.getProvincias(departamentoId);
  }
}
