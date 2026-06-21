/// Representa la configuración de integración con WhatsApp y el chatbot de IA.
class WhatsappSettings {
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

  /// Tipo o rubro del negocio (ej. "Venta de calzado").
  final String? businessType;

  /// Estilo del tono con el que responderá el chatbot (ej. "amigable").
  final String? toneStyle;

  /// Nombre que el bot utilizará para identificarse.
  final String? botName;

  /// Dirección URL del servidor de la API del bot de WhatsApp.
  final String? botUrl;

  /// Fecha y hora del último cambio realizado en la configuración.
  final DateTime? updatedAt;

  /// Crea una instancia de [WhatsappSettings].
  WhatsappSettings({
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

  /// Retorna una copia de la configuración actual con los campos actualizados.
  WhatsappSettings copyWith({
    String? phoneId,
    String? apiToken,
    String? verifyToken,
    String? aiApiKey,
    String? brandName,
    String? catalogUrl,
    String? businessType,
    String? toneStyle,
    String? botName,
    String? botUrl,
    DateTime? updatedAt,
  }) {
    return WhatsappSettings(
      phoneId: phoneId ?? this.phoneId,
      apiToken: apiToken ?? this.apiToken,
      verifyToken: verifyToken ?? this.verifyToken,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      brandName: brandName ?? this.brandName,
      catalogUrl: catalogUrl ?? this.catalogUrl,
      businessType: businessType ?? this.businessType,
      toneStyle: toneStyle ?? this.toneStyle,
      botName: botName ?? this.botName,
      botUrl: botUrl ?? this.botUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
