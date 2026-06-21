import 'package:virtual_catalog_app/domain/entities/whatsapp_settings.dart';

/// Interfaz del origen de datos para la configuración de WhatsApp.
abstract class WhatsappSettingsDatasource {
  /// Obtiene la configuración de WhatsApp asociada a un negocio mediante su [businessSlug].
  Future<WhatsappSettings?> getSettings(String businessSlug);

  /// Guarda la configuración de WhatsApp del negocio especificado por [businessSlug].
  Future<void> saveSettings(String businessSlug, WhatsappSettings settings);
}
