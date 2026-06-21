import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/whatsapp_settings_model.dart';
import 'package:virtual_catalog_app/domain/datasources/whatsapp_settings_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/whatsapp_settings.dart';

/// Implementación de [WhatsappSettingsDatasource] utilizando Cloud Firestore como persistencia.
class WhatsappSettingsDatasourceImpl implements WhatsappSettingsDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  /// Obtiene la configuración desde la colección `whatsapp_settings` en Firestore.
  Future<WhatsappSettings?> getSettings(String businessSlug) async {
    final doc = await _db.collection("whatsapp_settings").doc(businessSlug).get();
    if (!doc.exists) return null;
    return WhatsappSettingsModel.fromFirestore(doc).toEntity();
  }

  @override
  /// Guarda la configuración en la colección `whatsapp_settings` de Firestore utilizando la estrategia merge.
  Future<void> saveSettings(String businessSlug, WhatsappSettings settings) async {
    final model = WhatsappSettingsModel.fromEntity(settings);
    await _db.collection("whatsapp_settings").doc(businessSlug).set(
          model.toJson(),
          SetOptions(merge: true),
        );
  }
}
