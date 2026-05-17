import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/shipping_zone.dart';
import 'package:virtual_catalog_app/domain/usecases/get_shipping_zones.dart';
import 'package:virtual_catalog_app/domain/usecases/save_shipping_zones.dart';

class ShippingZoneProvider extends ChangeNotifier {
  final GetShippingZones _getShippingZones;
  final SaveShippingZones _saveShippingZones;

  List<ShippingZone> _zones = [];
  final Set<String> _selectedUbigeoCodes = {};
  bool _isLoading = false;
  bool _isSaving = false;

  List<ShippingZone> get zones => _zones;
  Set<String> get selectedUbigeoCodes => _selectedUbigeoCodes;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  ShippingZoneProvider({
    required GetShippingZones getShippingZones,
    required SaveShippingZones saveShippingZones,
  })  : _getShippingZones = getShippingZones,
        _saveShippingZones = saveShippingZones;

  Future<void> loadZones(String businessId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _zones = await _getShippingZones(businessId);
      _selectedUbigeoCodes.clear();
      for (final zone in _zones) {
        _selectedUbigeoCodes.add(zone.ubigeoCode);
      }
    } catch (e) {
      debugPrint('Error loading shipping zones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isSelected(String ubigeoCode) {
    return _selectedUbigeoCodes.contains(ubigeoCode);
  }

  void toggleZone({
    required String ubigeoCode,
    required String departamento,
    required String provincia,
    required String distrito,
  }) {
    if (_selectedUbigeoCodes.contains(ubigeoCode)) {
      _selectedUbigeoCodes.remove(ubigeoCode);
    } else {
      _selectedUbigeoCodes.add(ubigeoCode);
    }
    notifyListeners();
  }

  void selectMultiple(List<String> ubigeoCodes) {
    _selectedUbigeoCodes.addAll(ubigeoCodes);
    notifyListeners();
  }

  void deselectMultiple(List<String> ubigeoCodes) {
    _selectedUbigeoCodes.removeAll(ubigeoCodes);
    notifyListeners();
  }

  void selectAll(List<String> allCodes) {
    _selectedUbigeoCodes.addAll(allCodes);
    notifyListeners();
  }

  void deselectAll() {
    _selectedUbigeoCodes.clear();
    notifyListeners();
  }

  int countSelectedIn(List<String> codes) {
    return codes.where((c) => _selectedUbigeoCodes.contains(c)).length;
  }

  Future<void> saveZones({
    required String businessId,
    required Map<String, ZoneInfo> zoneInfoMap,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final zonesToSave = _selectedUbigeoCodes
          .where((code) => zoneInfoMap.containsKey(code))
          .map((code) {
        final info = zoneInfoMap[code]!;
        return ShippingZone(
          id: '',
          departamento: info.departamento,
          provincia: info.provincia,
          distrito: info.distrito,
          ubigeoCode: code,
        );
      }).toList();

      await _saveShippingZones(businessId, zonesToSave);
      _zones = zonesToSave;
    } catch (e) {
      debugPrint('Error saving shipping zones: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  List<String> get uniqueDepartamentos {
    return _zones.map((z) => z.departamento).toSet().toList()..sort();
  }

  List<String> provinciasForDepartamento(String departamento) {
    return _zones
        .where((z) => z.departamento == departamento)
        .map((z) => z.provincia)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> distritosForProvincia(String departamento, String provincia) {
    return _zones
        .where((z) => z.departamento == departamento && z.provincia == provincia)
        .map((z) => z.distrito)
        .toSet()
        .toList()
      ..sort();
  }
}

class ZoneInfo {
  final String departamento;
  final String provincia;
  final String distrito;

  ZoneInfo({
    required this.departamento,
    required this.provincia,
    required this.distrito,
  });
}
