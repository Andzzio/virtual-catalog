import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/config/themes/theme_config.dart';
import 'package:virtual_catalog_app/data/services/cloudinary_service.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';
import 'package:virtual_catalog_app/domain/entities/payment_method.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/settings/admin_settings_delivery_section.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/settings/admin_settings_payment_section.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class AdminSettingsView extends StatefulWidget {
  final String businessSlug;
  const AdminSettingsView({super.key, required this.businessSlug});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  final _formKey = GlobalKey<FormState>();
  final CloudinaryService _cloudinary = CloudinaryService();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _whatsappCtrl;
  late TextEditingController _termsCtrl;
  late TextEditingController _themeColorCtrl;
  late TextEditingController _bgColorCtrl;
  late TextEditingController _domainCtrl;
  late TextEditingController _apisPeruTokenCtrl;
  late TextEditingController _nubefactUrlCtrl;
  late TextEditingController _nubefactTokenCtrl;
  late TextEditingController _rucCtrl;
  late TextEditingController _addressCtrl;

  bool _showApisPeruToken = false;
  bool _showNubefactToken = false;
  Uint8List? _newLogo;
  String? _currentLogoUrl;
  List<DeliveryMethod> _deliveryMethods = [];
  List<PaymentMethod> _paymentMethods = [];
  String? _izipayUsername;
  String? _izipayPassword;
  String? _izipayPublicKey;
  bool _initialized = false;
  bool _isSaving = false;
  bool _showDesktopLogo = false;
  bool _showMobileLogo = false;

  void _initFromBusiness(Business business) {
    if (_initialized) return;
    _nameCtrl = TextEditingController(text: business.name);
    _descCtrl = TextEditingController(text: business.description);
    _whatsappCtrl = TextEditingController(text: business.whatsappNumber);
    _termsCtrl = TextEditingController(text: business.termsAndConditions ?? "");
    _themeColorCtrl = TextEditingController(text: business.themeColorHex ?? "");
    _bgColorCtrl = TextEditingController(
      text: business.backgroundColorHex ?? "",
    );
    _domainCtrl = TextEditingController(text: business.customDomain ?? "");
    _apisPeruTokenCtrl = TextEditingController(text: business.apisPeruToken ?? "");
    _nubefactUrlCtrl = TextEditingController(text: business.nubefactUrl ?? "");
    _nubefactTokenCtrl = TextEditingController(text: business.nubefactToken ?? "");
    _rucCtrl = TextEditingController(text: business.ruc ?? "");
    _addressCtrl = TextEditingController(text: business.address ?? "");
    _currentLogoUrl = business.logoUrl;
    _deliveryMethods = List.from(business.deliveryMethods);
    _paymentMethods = List.from(business.paymentMethods);
    _showDesktopLogo = business.showDesktopLogo;
    _showMobileLogo = business.showMobileLogo;
    _izipayUsername = business.izipayUsername;
    _izipayPassword = business.izipayPassword;
    _izipayPublicKey = business.izipayPublicKey;
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _nameCtrl.dispose();
      _descCtrl.dispose();
      _whatsappCtrl.dispose();
      _termsCtrl.dispose();
      _themeColorCtrl.dispose();
      _bgColorCtrl.dispose();
      _domainCtrl.dispose();
      _apisPeruTokenCtrl.dispose();
      _nubefactUrlCtrl.dispose();
      _nubefactTokenCtrl.dispose();
      _rucCtrl.dispose();
      _addressCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _newLogo = bytes);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final business = context.read<BusinessProvider>().business;
    if (business == null) return;

    setState(() => _isSaving = true);

    try {
      String logoUrl = _currentLogoUrl ?? "";
      if (_newLogo != null) {
        final fileName =
            "logo_${business.slug}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final result = await _cloudinary.uploadImage(_newLogo!, fileName);
        logoUrl = result["url"]!;
      }

      final updated = business.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        logoUrl: logoUrl,
        whatsappNumber: _whatsappCtrl.text.trim(),
        deliveryMethods: _deliveryMethods,
        paymentMethods: _paymentMethods,
        showDesktopLogo: _showDesktopLogo,
        showMobileLogo: _showMobileLogo,
        termsAndConditions: _termsCtrl.text.trim(),
        izipayUsername: _izipayUsername,
        izipayPassword: _izipayPassword,
        izipayPublicKey: _izipayPublicKey,
        themeColorHex: _themeColorCtrl.text.trim().isEmpty ? null : _themeColorCtrl.text.trim(),
        backgroundColorHex: _bgColorCtrl.text.trim().isEmpty ? null : _bgColorCtrl.text.trim(),
        customDomain: _domainCtrl.text.trim().isEmpty ? null : _domainCtrl.text.trim(),
        apisPeruToken: _apisPeruTokenCtrl.text.trim().isEmpty ? null : _apisPeruTokenCtrl.text.trim(),
        nubefactUrl: _nubefactUrlCtrl.text.trim().isEmpty ? null : _nubefactUrlCtrl.text.trim(),
        nubefactToken: _nubefactTokenCtrl.text.trim().isEmpty ? null : _nubefactTokenCtrl.text.trim(),
        ruc: _rucCtrl.text.trim().isEmpty ? null : _rucCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      );

      if (!mounted) return;
      await context.read<BusinessProvider>().updateBusiness(updated);

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Configuración guardada")));
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    final business = provider.business;

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AdminTheme.accent),
      );
    }
    if (business == null) {
      return const Center(child: Text("No se pudo cargar el negocio."));
    }

    _initFromBusiness(business);

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.cardBg,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AdminTheme.border, height: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Configuración", style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            Text("Ajustes generales de tu negocio.", style: AdminTheme.bodySmall()),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save),
            style: AdminTheme.primaryButton(),
            label: Text("Guardar Cambios", style: GoogleFonts.getFont(FontNames.fontNameH2)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < AdminTheme.breakpointMobile;
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 80,
                  vertical: isMobile ? 16 : 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // General Info Section
                    _buildSectionHeader(
                      Icons.storefront_outlined,
                      "Información General",
                    ),
                    const SizedBox(height: 16),
                    _buildGeneralSection(business),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    // Domain Section
                    _buildSectionHeader(Icons.language_outlined, "Dominio Personalizado"),
                    const SizedBox(height: 16),
                    _buildDomainSection(),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    // Contact Section
                    _buildSectionHeader(Icons.phone_outlined, "Contacto"),
                    const SizedBox(height: 16),
                    _buildContactSection(),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    // Colors section
                    _buildSectionHeader(
                      Icons.palette_outlined,
                      "Colores y Personalización",
                    ),
                    const SizedBox(height: 16),
                    _buildColorsSection(),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    // Delivery Methods
                    AdminSettingsDeliverySection(
                      methods: _deliveryMethods,
                      onChanged: (val) =>
                          setState(() => _deliveryMethods = val),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    // Payment Methods
                    AdminSettingsPaymentSection(
                      methods: _paymentMethods,
                      onChanged: (val) => setState(() => _paymentMethods = val),
                      izipayUsername: _izipayUsername,
                      izipayPassword: _izipayPassword,
                      izipayPublicKey: _izipayPublicKey,
                      onIzipayCredentialsChanged: (creds) {
                        setState(() {
                          _izipayUsername = creds["izipayUsername"];
                          _izipayPassword = creds["izipayPassword"];
                          _izipayPublicKey = creds["izipayPublicKey"];
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      Icons.receipt_long_outlined,
                      "Facturación Electrónica (Nubefact)",
                    ),
                    const SizedBox(height: 16),
                    _buildNubefactSection(),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      Icons.search_outlined,
                      "Consulta DNI/RUC",
                    ),
                    const SizedBox(height: 16),
                    _buildApisPeruSection(),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      Icons.text_snippet_outlined,
                      "Pie de página",
                    ),
                    const SizedBox(height: 16),
                    _buildFooterSection(),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      Icons.settings_applications,
                      "Opciones varias",
                    ),
                    const SizedBox(height: 16),
                    _buildMiscSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorPickerRow(
            "Color de Acento del Tema",
            "Define el color de los botones principales.",
            _themeColorCtrl,
          ),
          const SizedBox(height: 20),
          _buildColorPickerRow(
            "Color de Fondo",
            "Personaliza el fondo del catálogo.",
            _bgColorCtrl,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerRow(
    String label,
    String description,
    TextEditingController controller,
  ) {
    Color currentColor =
        ThemeConfig.hexToColor(controller.text) ??
        (label == "Color de Acento del Tema"
            ? Colors.black
            : label == "Color de Fondo"
            ? Colors.white
            : Colors.grey[400]!);

    // Skill: Use LayoutBuilder for responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;

        final colorSwatch = GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                Color pickedColor = currentColor;
                return AlertDialog(
                  title: Text("Selecciona el $label", style: GoogleFonts.getFont(FontNames.fontNameH2)),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickedColor,
                      onColorChanged: (color) { pickedColor = color; },
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                    FilledButton(
                      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(AdminTheme.accent)),
                      onPressed: () {
                        setState(() {
                          final hex = '#${pickedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                          controller.text = hex;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Seleccionar"),
                    ),
                  ],
                );
              },
            );
          },
          child: Tooltip(
            message: "Abrir selector de color",
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: currentColor == Colors.white ? Colors.grey[300]! : AdminTheme.border, width: 1.5),
                boxShadow: AdminTheme.cardShadow,
              ),
              child: Center(
                child: Icon(Icons.palette_outlined,
                  color: currentColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white70, size: 20),
              ),
            ),
          ),
        );

        final hexField = SizedBox(
          width: isNarrow ? double.infinity : 120,
          child: TextFormField(
            controller: controller,
            decoration: _inputDecoration("#HEX"),
            style: GoogleFonts.getFont(FontNames.fontNameH2),
            onChanged: (val) => setState(() {}),
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                colorSwatch,
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                    Text(description, style: AdminTheme.caption()),
                  ],
                )),
              ]),
              const SizedBox(height: 8),
              hexField,
            ],
          );
        }

        return Row(
          children: [
            colorSwatch,
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.getFont(FontNames.fontNameH2, textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(height: 2),
                Text(description, style: AdminTheme.caption()),
              ],
            )),
            const SizedBox(width: 16),
            hexField,
          ],
        );
      },
    );
  }

  Widget _buildApisPeruSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Token de APIs Perú",
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
            controller: _apisPeruTokenCtrl,
            obscureText: !_showApisPeruToken,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(fontSize: 13),
            ),
            decoration: AdminTheme.inputDecoration(
              hintText: "Token para consulta de RUC/DNI",
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showApisPeruToken = !_showApisPeruToken),
                icon: Icon(
                  _showApisPeruToken ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: AdminTheme.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Permite consultar DNI y RUC de clientes de forma automática mediante la API de dniruc.apisperu.com.",
            style: AdminTheme.caption(),
          ),
        ],
      ),
    );
  }

  Widget _buildNubefactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ruta / Endpoint",
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
            controller: _nubefactUrlCtrl,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(fontSize: 13),
            ),
            decoration: AdminTheme.inputDecoration(
              hintText: "https://api.nubefact.com/api/v1/...",
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Token de Nubefact",
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
            controller: _nubefactTokenCtrl,
            obscureText: !_showNubefactToken,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(fontSize: 13),
            ),
            decoration: AdminTheme.inputDecoration(
              hintText: "Token proporcionado por Nubefact",
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showNubefactToken = !_showNubefactToken),
                icon: Icon(
                  _showNubefactToken ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: AdminTheme.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Configura tu cuenta de Nubefact para emitir Boletas y Facturas electrónicas con validez SUNAT. El Certificado Digital y Clave SOL se gestionan directamente en Nubefact.",
            style: AdminTheme.caption(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Container(
      decoration: AdminTheme.cardDecoration(),
      padding: const EdgeInsets.all(8.0),
      child: MarkdownAutoPreview(controller: _termsCtrl, emojiConvert: true),
    );
  }

  Widget _buildMiscSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Mostrar logo en Escritorio", style: GoogleFonts.getFont(FontNames.fontNameH2)),
            subtitle: Text("Logo visible en la versión de PC", style: AdminTheme.caption()),
            value: _showDesktopLogo,
            onChanged: (value) => setState(() => _showDesktopLogo = value),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Mostrar logo en Móvil", style: GoogleFonts.getFont(FontNames.fontNameH2)),
            subtitle: Text("Logo visible en celulares", style: AdminTheme.caption()),
            value: _showMobileLogo,
            onChanged: (value) => setState(() => _showMobileLogo = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AdminTheme.textSecondary),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Skill: LayoutBuilder for responsive Row→Column
  Widget _buildGeneralSection(Business business) {
    final logoWidget = Column(
      children: [
        GestureDetector(
          onTap: _pickLogo,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              border: Border.all(color: AdminTheme.border),
              color: AdminTheme.surface,
            ),
            child: _newLogo != null
                ? ClipRRect(borderRadius: BorderRadius.circular(AdminTheme.radiusMd), child: Image.memory(_newLogo!, fit: BoxFit.cover))
                : (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty)
                ? ClipRRect(borderRadius: BorderRadius.circular(AdminTheme.radiusMd), child: Image.network(_currentLogoUrl!, fit: BoxFit.cover))
                : Icon(Icons.add_a_photo, color: AdminTheme.textMuted),
          ),
        ),
        const SizedBox(height: 6),
        Text("Logo", style: AdminTheme.caption()),
      ],
    );

    final fieldsWidget = Column(
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: _inputDecoration("Nombre del negocio"),
          style: GoogleFonts.getFont(FontNames.fontNameH2),
          validator: (v) => (v == null || v.trim().isEmpty) ? "Requerido" : null,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 450;
            final rucField = TextFormField(
              controller: _rucCtrl,
              decoration: _inputDecoration("R.U.C. del negocio (opcional)"),
              style: GoogleFonts.getFont(FontNames.fontNameH2),
              keyboardType: TextInputType.number,
            );
            final addressField = TextFormField(
              controller: _addressCtrl,
              decoration: _inputDecoration("Dirección física del negocio (opcional)"),
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            );

            if (isNarrow) {
              return Column(
                children: [
                  rucField,
                  const SizedBox(height: 14),
                  addressField,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: rucField),
                const SizedBox(width: 14),
                Expanded(child: addressField),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _descCtrl,
          decoration: _inputDecoration("Descripción"),
          style: GoogleFonts.getFont(FontNames.fontNameH2),
          maxLines: 3,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AdminTheme.breakpointMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [logoWidget, const SizedBox(height: 16), fieldsWidget],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [logoWidget, const SizedBox(width: 24), Expanded(child: fieldsWidget)],
        );
      },
    );
  }

  Widget _buildDomainSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _domainCtrl,
                  decoration: _inputDecoration("ejemplo: mitienda.com"),
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: "Para activar tu dominio propio, debes contactar al proveedor del catálogo\npara la configuración inicial de DNS (Registros A y TXT).",
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                showDuration: const Duration(seconds: 4),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.amber,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Si no tienes un dominio configurado, deja este campo en blanco.",
            style: AdminTheme.caption(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Row(
      children: [
        const Icon(Icons.phone, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _whatsappCtrl,
            decoration: _inputDecoration(
              "Número de WhatsApp (ej: 51999999999)",
            ),
            style: GoogleFonts.getFont(FontNames.fontNameH2),
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Requerido" : null,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return AdminTheme.inputDecoration(hintText: hint);
  }
}
