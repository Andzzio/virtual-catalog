import 'package:virtual_catalog_app/domain/datasources/whatsapp_settings_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/whatsapp_settings.dart';
import 'package:virtual_catalog_app/domain/repos/whatsapp_settings_repository.dart';

/// Implementación de [WhatsappSettingsRepository] que delega las operaciones a un [WhatsappSettingsDatasource].
class WhatsappSettingsRepositoryImpl implements WhatsappSettingsRepository {
  /// Origen de datos utilizado por este repositorio.
  final WhatsappSettingsDatasource datasource;

  /// Crea una instancia de [WhatsappSettingsRepositoryImpl].
  WhatsappSettingsRepositoryImpl({required this.datasource});

  @override
  /// Obtiene la configuración de WhatsApp delegando al [datasource].
  Future<WhatsappSettings?> getSettings(String businessSlug) {
    return datasource.getSettings(businessSlug);
  }

  @override
  /// Guarda la configuración de WhatsApp delegando al [datasource].
  Future<void> saveSettings(String businessSlug, WhatsappSettings settings) {
    return datasource.saveSettings(businessSlug, settings);
  }
}
