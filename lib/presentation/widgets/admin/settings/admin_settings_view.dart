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

      final updated = Business(
        slug: business.slug,
        ownerId: business.ownerId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        logoUrl: logoUrl,
        whatsappNumber: _whatsappCtrl.text.trim(),
        banners: business.banners,
        deliveryMethods: _deliveryMethods,
        paymentMethods: _paymentMethods,
        showDesktopLogo: _showDesktopLogo,
        showMobileLogo: _showMobileLogo,
        termsAndConditions: _termsCtrl.text.trim(),
        homeBlocks: business.homeBlocks,
        izipayUsername: _izipayUsername,
        izipayPassword: _izipayPassword,
        izipayPublicKey: _izipayPublicKey,
        themeColorHex: _themeColorCtrl.text.trim().isEmpty
            ? null
            : _themeColorCtrl.text.trim(),
        backgroundColorHex: _bgColorCtrl.text.trim().isEmpty
            ? null
            : _bgColorCtrl.text.trim(),
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
        child: CircularProgressIndicator(color: Colors.black),
      );
    }
    if (business == null) {
      return const Center(child: Text("No se pudo cargar el negocio."));
    }

    _initFromBusiness(business);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E2E2), height: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Configuración",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "Ajustes generales de tu negocio.",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            label: Text(
              "Guardar Cambios",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorPickerRow(
            "Color de Acento del Tema",
            "Define el color de los botones principales, título del negocio y controles activos.",
            _themeColorCtrl,
          ),
          const SizedBox(height: 20),
          _buildColorPickerRow(
            "Color de Fondo",
            "Personaliza el fondo de las páginas del catálogo para los clientes.",
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

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                Color pickedColor = currentColor;
                return AlertDialog(
                  title: Text(
                    "Selecciona el $label",
                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                  ),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickedColor,
                      onColorChanged: (color) {
                        pickedColor = color;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                    FilledButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                      ),
                      onPressed: () {
                        setState(() {
                          final hex =
                              '#${pickedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
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
            message: "Hacer clic para abrir el selector de color",
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentColor == Colors.white
                        ? Colors.grey[300]!
                        : const Color(0xFFE2E2E2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.palette_outlined,
                    color: currentColor.computeLuminance() > 0.5
                        ? Colors.black87
                        : Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 120,
          child: TextFormField(
            controller: controller,
            decoration: _inputDecoration("#HEX"),
            style: GoogleFonts.getFont(FontNames.fontNameH2),
            onChanged: (val) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E2E2)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(8.0),
      child: MarkdownAutoPreview(controller: _termsCtrl, emojiConvert: true),
    );
  }

  Widget _buildMiscSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mostrar logo del Negocio en la vista de Escritorio",
                style: GoogleFonts.getFont(FontNames.fontNameH2),
              ),
              Switch(
                value: _showDesktopLogo,
                onChanged: (value) {
                  _showDesktopLogo = value;
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mostrar logo del Negocio en la vista de Móvil",
                style: GoogleFonts.getFont(FontNames.fontNameH2),
              ),
              Switch(
                value: _showMobileLogo,
                onChanged: (value) {
                  _showMobileLogo = value;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
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

  Widget _buildGeneralSection(Business business) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: _pickLogo,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E2E2)),
                  color: Colors.grey[50],
                ),
                child: _newLogo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_newLogo!, fit: BoxFit.cover),
                      )
                    : (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _currentLogoUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.add_a_photo, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Logo",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: _inputDecoration("Nombre del negocio"),
                style: GoogleFonts.getFont(FontNames.fontNameH2),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Requerido" : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                decoration: _inputDecoration("Descripción"),
                style: GoogleFonts.getFont(FontNames.fontNameH2),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
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
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.getFont(
        FontNames.fontNameH2,
        textStyle: TextStyle(color: Colors.grey[400]),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
