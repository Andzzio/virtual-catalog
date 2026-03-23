import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/data/services/cloudinary_service.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';
import 'package:virtual_catalog_app/domain/entities/payment_method.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/settings/admin_settings_delivery_section.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/settings/admin_settings_payment_section.dart';

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

  Uint8List? _newLogo;
  String? _currentLogoUrl;
  List<DeliveryMethod> _deliveryMethods = [];
  List<PaymentMethod> _paymentMethods = [];
  bool _initialized = false;
  bool _isSaving = false;

  void _initFromBusiness(Business business) {
    if (_initialized) return;
    _nameCtrl = TextEditingController(text: business.name);
    _descCtrl = TextEditingController(text: business.description);
    _whatsappCtrl = TextEditingController(text: business.whatsappNumber);
    _currentLogoUrl = business.logoUrl;
    _deliveryMethods = List.from(business.deliveryMethods);
    _paymentMethods = List.from(business.paymentMethods);
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _nameCtrl.dispose();
      _descCtrl.dispose();
      _whatsappCtrl.dispose();
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
        final fileName = "logo_${business.slug}_${DateTime.now().millisecondsSinceEpoch}.jpg";
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
      );

      if (!mounted) return;
      await context.read<BusinessProvider>().updateBusiness(updated);

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Configuración guardada")),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    final business = provider.business;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
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
                _buildSectionHeader(
                  Icons.phone_outlined,
                  "Contacto",
                ),
                const SizedBox(height: 16),
                _buildContactSection(),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 30),
                // Delivery Methods
                AdminSettingsDeliverySection(
                  methods: _deliveryMethods,
                  onChanged: (val) => setState(() => _deliveryMethods = val),
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 30),
                // Payment Methods
                AdminSettingsPaymentSection(
                  methods: _paymentMethods,
                  onChanged: (val) => setState(() => _paymentMethods = val),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
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
        // Logo
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
        // Name & Description
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
            decoration: _inputDecoration("Número de WhatsApp (ej: 51999999999)"),
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
