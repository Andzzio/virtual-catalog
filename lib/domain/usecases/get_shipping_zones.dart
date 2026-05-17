import 'package:virtual_catalog_app/domain/entities/shipping_zone.dart';
import 'package:virtual_catalog_app/domain/repos/shipping_zone_repository.dart';

class GetShippingZones {
  final ShippingZoneRepository repository;

  GetShippingZones(this.repository);

  Future<List<ShippingZone>> call(String businessId) {
    return repository.getZones(businessId);
  }
}
