import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/repos/business_repository.dart';

class GetBusinessByDomain {
  final BusinessRepository repository;

  GetBusinessByDomain(this.repository);

  Future<Business?> call(String domain) {
    return repository.getBusinessByDomain(domain);
  }
}
