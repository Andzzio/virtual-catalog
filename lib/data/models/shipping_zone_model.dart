import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/domain/entities/shipping_zone.dart';

class ShippingZoneModel {
  final String id;
  final String departamento;
  final String provincia;
  final String distrito;
  final String ubigeoCode;

  ShippingZoneModel({
    required this.id,
    required this.departamento,
    required this.provincia,
    required this.distrito,
    required this.ubigeoCode,
  });

  factory ShippingZoneModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ShippingZoneModel(
      id: doc.id,
      departamento: data['departamento'] ?? '',
      provincia: data['provincia'] ?? '',
      distrito: data['distrito'] ?? '',
      ubigeoCode: data['ubigeoCode'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'departamento': departamento,
      'provincia': provincia,
      'distrito': distrito,
      'ubigeoCode': ubigeoCode,
    };
  }

  ShippingZone toEntity() {
    return ShippingZone(
      id: id,
      departamento: departamento,
      provincia: provincia,
      distrito: distrito,
      ubigeoCode: ubigeoCode,
    );
  }

  factory ShippingZoneModel.fromEntity(ShippingZone entity) {
    return ShippingZoneModel(
      id: entity.id,
      departamento: entity.departamento,
      provincia: entity.provincia,
      distrito: entity.distrito,
      ubigeoCode: entity.ubigeoCode,
    );
  }
}
