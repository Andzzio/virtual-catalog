import 'package:virtual_catalog_app/domain/entities/ubigeo.dart';
import 'package:virtual_catalog_app/domain/repos/ubigeo_repository.dart';

class GetDepartamentos {
  final UbigeoRepository repository;

  GetDepartamentos(this.repository);

  Future<List<Ubigeo>> call() {
    return repository.getDepartamentos();
  }
}
