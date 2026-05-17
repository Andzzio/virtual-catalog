import 'package:virtual_catalog_app/domain/entities/shipping_zone.dart';
import 'package:virtual_catalog_app/domain/repos/shipping_zone_repository.dart';

class SaveShippingZones {
  final ShippingZoneRepository repository;

  SaveShippingZones(this.repository);

  Future<void> call(String businessId, List<ShippingZone> zones) {
    return repository.saveZones(businessId, zones);
  }
}
