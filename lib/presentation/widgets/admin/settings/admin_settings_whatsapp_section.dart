import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/whatsapp_settings.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminSettingsWhatsappSection extends StatefulWidget {
  final WhatsappSettings? settings;
  final ValueChanged<WhatsappSettings> onSettingsChanged;

  const AdminSettingsWhatsappSection({
    super.key,
    this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<AdminSettingsWhatsappSection> createState() =>
      _AdminSettingsWhatsappSectionState();
}

class _AdminSettingsWhatsappSectionState
    extends State<AdminSettingsWhatsappSection> {
  bool _showApiToken = false;
  bool _showVerifyToken = false;
  bool _showAiApiKey = false;

  late TextEditingController _phoneIdCtrl;
  late TextEditingController _apiTokenCtrl;
  late TextEditingController _verifyTokenCtrl;
  late TextEditingController _aiApiKeyCtrl;
  late TextEditingController _botNameCtrl;
  late TextEditingController _brandNameCtrl;
  late TextEditingController _businessTypeCtrl;
  late TextEditingController _catalogUrlCtrl;
  late TextEditingController _botUrlCtrl;
  String? _toneStyle;

  bool _initialized = false;

  @override
  void didUpdateWidget(covariant AdminSettingsWhatsappSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_initialized) {
      _initControllers();
    }
  }

  void _initControllers() {
    if (_initialized) return;
    _phoneIdCtrl = TextEditingController(text: widget.settings?.phoneId ?? "");
    _apiTokenCtrl = TextEditingController(text: widget.settings?.apiToken ?? "");
    _verifyTokenCtrl = TextEditingController(text: widget.settings?.verifyToken ?? "");
    _aiApiKeyCtrl = TextEditingController(text: widget.settings?.aiApiKey ?? "");
    _botNameCtrl = TextEditingController(text: widget.settings?.botName ?? "");
    _brandNameCtrl = TextEditingController(text: widget.settings?.brandName ?? "");
    _businessTypeCtrl = TextEditingController(text: widget.settings?.businessType ?? "");
    _catalogUrlCtrl = TextEditingController(text: widget.settings?.catalogUrl ?? "");
    _botUrlCtrl = TextEditingController(text: widget.settings?.botUrl ?? "");
    _toneStyle = widget.settings?.toneStyle ?? "amigable";
    _initialized = true;
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void dispose() {
    if (_initialized) {
      _phoneIdCtrl.dispose();
      _apiTokenCtrl.dispose();
      _verifyTokenCtrl.dispose();
      _aiApiKeyCtrl.dispose();
      _botNameCtrl.dispose();
      _brandNameCtrl.dispose();
      _businessTypeCtrl.dispose();
      _catalogUrlCtrl.dispose();
      _botUrlCtrl.dispose();
    }
    super.dispose();
  }

  void _emitChanges() {
    final updated = WhatsappSettings(
      phoneId: _phoneIdCtrl.text.trim().isEmpty ? null : _phoneIdCtrl.text.trim(),
      apiToken: _apiTokenCtrl.text.trim().isEmpty ? null : _apiTokenCtrl.text.trim(),
      verifyToken: _verifyTokenCtrl.text.trim().isEmpty ? null : _verifyTokenCtrl.text.trim(),
      aiApiKey: _aiApiKeyCtrl.text.trim().isEmpty ? null : _aiApiKeyCtrl.text.trim(),
      botName: _botNameCtrl.text.trim().isEmpty ? null : _botNameCtrl.text.trim(),
      brandName: _brandNameCtrl.text.trim().isEmpty ? null : _brandNameCtrl.text.trim(),
      businessType: _businessTypeCtrl.text.trim().isEmpty ? null : _businessTypeCtrl.text.trim(),
      catalogUrl: _catalogUrlCtrl.text.trim().isEmpty ? null : _catalogUrlCtrl.text.trim(),
      botUrl: _botUrlCtrl.text.trim().isEmpty ? null : _botUrlCtrl.text.trim(),
      toneStyle: _toneStyle,
      updatedAt: widget.settings?.updatedAt,
    );
    widget.onSettingsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.chat_outlined, color: AdminTheme.textSecondary),
            const SizedBox(width: 10),
            Text(
              "Configuración de WhatsApp",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWhatsappCredentialsPanel(),
        const SizedBox(height: 20),
        _buildBotConfigPanel(),
      ],
    );
  }

  Widget _buildWhatsappCredentialsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminTheme.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.settings_phone_outlined,
                      size: 14,
                      color: AdminTheme.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Credenciales de WhatsApp",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneIdCtrl,
            label: "ID de Teléfono",
            hint: "Ej: 1065489725",
            onChanged: (_) => _emitChanges(),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _botUrlCtrl,
            label: "URL de la API del Bot",
            hint: "Ej: https://mitienda-bot.up.railway.app",
            onChanged: (_) => _emitChanges(),
          ),
          const SizedBox(height: 12),
          _buildSecureField(
            controller: _apiTokenCtrl,
            label: "API Token (Meta)",
            hint: "Token de acceso permanente",
            isVisible: _showApiToken,
            onToggle: () => setState(() => _showApiToken = !_showApiToken),
            onChanged: (_) => _emitChanges(),
          ),
          const SizedBox(height: 12),
          _buildSecureField(
            controller: _verifyTokenCtrl,
            label: "Verify Token (Webhook)",
            hint: "Token de verificación para Webhooks",
            isVisible: _showVerifyToken,
            onToggle: () => setState(() => _showVerifyToken = !_showVerifyToken),
            onChanged: (_) => _emitChanges(),
          ),
        ],
      ),
    );
  }

  Widget _buildBotConfigPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminTheme.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.android_outlined,
                      size: 14,
                      color: AdminTheme.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Configuración del Bot IA",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSecureField(
            controller: _aiApiKeyCtrl,
            label: "AI API Key de Claude",
            hint: "Ingrese su API Key de Claude/Anthropic",
            isVisible: _showAiApiKey,
            onToggle: () => setState(() => _showAiApiKey = !_showAiApiKey),
            onChanged: (_) => _emitChanges(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "AI API Key de Claude es requerida";
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _botNameCtrl,
            label: "Nombre del Bot",
            hint: "Ej: Asistente Virtual",
            onChanged: (_) => _emitChanges(),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _brandNameCtrl,
            label: "Nombre de la Marca",
            hint: "Ej: Mi Tienda S.A.C.",
            onChanged: (_) => _emitChanges(),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _businessTypeCtrl,
            label: "Tipo de Negocio",
            hint: "Ej: Venta de ropa, tecnología, etc.",
            onChanged: (_) => _emitChanges(),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _catalogUrlCtrl,
            label: "URL del Catálogo",
            hint: "Ej: https://mitienda.com/catalogo",
            onChanged: (_) => _emitChanges(),
          ),
          const SizedBox(height: 12),
          _buildToneStyleDropdown(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AdminTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(fontSize: 13),
          ),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildSecureField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AdminTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          onChanged: onChanged,
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(fontSize: 13),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(color: AdminTheme.textMuted, fontSize: 13),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: AdminTheme.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AdminTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AdminTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AdminTheme.accent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                size: 18,
                color: AdminTheme.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToneStyleDropdown() {
    final styles = ["amigable", "formal", "casual", "profesional"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Estilo de Tono",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AdminTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _toneStyle,
          dropdownColor: AdminTheme.cardBgElevated,
          decoration: _inputDecoration("Selecciona un estilo"),
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(
              fontSize: 13,
              color: AdminTheme.textPrimary,
            ),
          ),
          items: styles
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _toneStyle = val;
            });
            _emitChanges();
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return AdminTheme.inputDecoration(hintText: hint).copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
