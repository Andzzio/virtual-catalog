import 'package:virtual_catalog_app/domain/entities/shipping_zone.dart';

abstract class ShippingZoneDatasource {
  Future<List<ShippingZone>> getZones(String businessId);
  Future<void> saveZones(String businessId, List<ShippingZone> zones);
  Future<void> deleteAllZones(String businessId);
}
