import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/whatsapp_settings.dart';
import 'package:virtual_catalog_app/domain/repos/whatsapp_settings_repository.dart';

/// Proveedor de estado para gestionar la configuración de WhatsApp y el chatbot.
class WhatsappSettingsProvider extends ChangeNotifier {
  /// Repositorio utilizado para acceder y guardar la configuración.
  final WhatsappSettingsRepository repository;

  /// La configuración actual de WhatsApp del negocio.
  WhatsappSettings? settings;

  /// Indica si hay una operación asíncrona de carga en curso.
  bool isLoading = false;

  /// Indica si la configuración ya ha sido cargada al menos una vez.
  bool hasLoaded = false;

  /// Crea una instancia de [WhatsappSettingsProvider].
  WhatsappSettingsProvider({required this.repository});

  /// Carga la configuración de WhatsApp para el negocio especificado por [slug].
  Future<void> loadSettings(String slug) async {
    isLoading = true;
    hasLoaded = false;
    notifyListeners();

    settings = await repository.getSettings(slug);

    isLoading = false;
    hasLoaded = true;
    notifyListeners();
  }

  /// Guarda de forma optimista la configuración de WhatsApp [updated] para el negocio [slug].
  /// En caso de error, revierte los cambios al estado previo.
  Future<void> saveSettings(String slug, WhatsappSettings updated) async {
    final backup = settings;
    settings = updated;
    notifyListeners();

    try {
      await repository.saveSettings(slug, updated);
    } catch (e) {
      settings = backup;
      notifyListeners();
      rethrow;
    }
  }
}
