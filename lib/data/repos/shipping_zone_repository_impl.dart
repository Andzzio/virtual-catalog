import 'package:virtual_catalog_app/domain/datasources/shipping_zone_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/shipping_zone.dart';
import 'package:virtual_catalog_app/domain/repos/shipping_zone_repository.dart';

class ShippingZoneRepositoryImpl implements ShippingZoneRepository {
  final ShippingZoneDatasource datasource;

  ShippingZoneRepositoryImpl({required this.datasource});

  @override
  Future<List<ShippingZone>> getZones(String businessId) {
    return datasource.getZones(businessId);
  }

  @override
  Future<void> saveZones(String businessId, List<ShippingZone> zones) {
    return datasource.saveZones(businessId, zones);
  }

  @override
  Future<void> deleteAllZones(String businessId) {
    return datasource.deleteAllZones(businessId);
  }
}
