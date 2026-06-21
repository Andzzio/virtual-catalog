import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/domain/entities/whatsapp_settings.dart';

/// Modelo de datos para [WhatsappSettings], utilizado para la serialización y persistencia.
class WhatsappSettingsModel {
  /// Identificador del número de teléfono en la API de WhatsApp Cloud.
  final String? phoneId;

  /// Token de acceso para realizar peticiones a la API de WhatsApp Cloud.
  final String? apiToken;

  /// Token de verificación configurado para el webhook de WhatsApp.
  final String? verifyToken;

  /// Clave de API para el servicio de Inteligencia Artificial (Claude).
  final String? aiApiKey;

  /// Nombre comercial de la marca del negocio.
  final String? brandName;

  /// Dirección URL del catálogo del negocio.
  final String? catalogUrl;

  /// Tipo o rubro del negocio.
  final String? businessType;

  /// Estilo del tono con el que responderá el chatbot.
  final String? toneStyle;

  /// Nombre que el bot utilizará para identificarse.
  final String? botName;

  /// Dirección URL del servidor de la API del bot de WhatsApp.
  final String? botUrl;

  /// Fecha y hora del último cambio realizado en la configuración.
  final DateTime? updatedAt;

  /// Crea una instancia de [WhatsappSettingsModel].
  WhatsappSettingsModel({
    this.phoneId,
    this.apiToken,
    this.verifyToken,
    this.aiApiKey,
    this.brandName,
    this.catalogUrl,
    this.businessType,
    this.toneStyle,
    this.botName,
    this.botUrl,
    this.updatedAt,
  });

  /// Mapea un documento de Firestore [DocumentSnapshot] a una instancia de [WhatsappSettingsModel].
  factory WhatsappSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>? ?? {};
    return WhatsappSettingsModel(
      phoneId: json['phoneId'] as String?,
      apiToken: json['apiToken'] as String?,
      verifyToken: json['verifyToken'] as String?,
      aiApiKey: json['aiApiKey'] as String?,
      brandName: json['brandName'] as String?,
      catalogUrl: json['catalogUrl'] as String?,
      businessType: json['businessType'] as String?,
      toneStyle: json['toneStyle'] as String?,
      botName: json['botName'] as String?,
      botUrl: json['botUrl'] as String?,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['updatedAt'] as String))
          : null,
    );
  }

  /// Mapea un objeto JSON [Map] a una instancia de [WhatsappSettingsModel].
  factory WhatsappSettingsModel.fromJson(Map<String, dynamic> json) {
    return WhatsappSettingsModel(
      phoneId: json['phoneId'] as String?,
      apiToken: json['apiToken'] as String?,
      verifyToken: json['verifyToken'] as String?,
      aiApiKey: json['aiApiKey'] as String?,
      brandName: json['brandName'] as String?,
      catalogUrl: json['catalogUrl'] as String?,
      businessType: json['businessType'] as String?,
      toneStyle: json['toneStyle'] as String?,
      botName: json['botName'] as String?,
      botUrl: json['botUrl'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convierte la instancia del modelo en un mapa JSON [Map].
  Map<String, dynamic> toJson() => {
    if (phoneId != null) 'phoneId': phoneId,
    if (apiToken != null) 'apiToken': apiToken,
    if (verifyToken != null) 'verifyToken': verifyToken,
    if (aiApiKey != null) 'aiApiKey': aiApiKey,
    if (brandName != null) 'brandName': brandName,
    if (catalogUrl != null) 'catalogUrl': catalogUrl,
    if (businessType != null) 'businessType': businessType,
    if (toneStyle != null) 'toneStyle': toneStyle,
    if (botName != null) 'botName': botName,
    if (botUrl != null) 'botUrl': botUrl,
    if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Convierte la instancia del modelo en una entidad de dominio [WhatsappSettings].
  WhatsappSettings toEntity() => WhatsappSettings(
    phoneId: phoneId,
    apiToken: apiToken,
    verifyToken: verifyToken,
    aiApiKey: aiApiKey,
    brandName: brandName,
    catalogUrl: catalogUrl,
    businessType: businessType,
    toneStyle: toneStyle,
    botName: botName,
    botUrl: botUrl,
    updatedAt: updatedAt,
  );

  /// Crea una instancia de [WhatsappSettingsModel] a partir de la entidad de dominio [WhatsappSettings].
  factory WhatsappSettingsModel.fromEntity(WhatsappSettings entity) {
    return WhatsappSettingsModel(
      phoneId: entity.phoneId,
      apiToken: entity.apiToken,
      verifyToken: entity.verifyToken,
      aiApiKey: entity.aiApiKey,
      brandName: entity.brandName,
      catalogUrl: entity.catalogUrl,
      businessType: entity.businessType,
      toneStyle: entity.toneStyle,
      botName: entity.botName,
      botUrl: entity.botUrl,
      updatedAt: entity.updatedAt,
    );
  }
}
