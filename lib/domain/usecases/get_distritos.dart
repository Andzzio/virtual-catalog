import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';
import 'package:virtual_catalog_app/domain/repos/ubigeo_repository.dart';

class GetDistritos {
  final UbigeoRepository repository;

  GetDistritos(this.repository);

  Future<List<Ubigeo>> call(String provinciaId) {
    return repository.getDistritos(provinciaId);
  }
}
