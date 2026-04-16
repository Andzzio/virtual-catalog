import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/data/services/cloudinary_service.dart';

class AdminBannerDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialSubtitle;
  final String? initialImageUrl;
  final String? initialMobileImageUrl;

  const AdminBannerDialog({
    super.key,
    this.initialTitle,
    this.initialSubtitle,
    this.initialImageUrl,
    this.initialMobileImageUrl,
  });

  @override
  State<AdminBannerDialog> createState() => _AdminBannerDialogState();
}

class _AdminBannerDialogState extends State<AdminBannerDialog> {
  final _formKey = GlobalKey<FormState>();
  final CloudinaryService _cloudinary = CloudinaryService();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;

  Uint8List? _selectedImage;
  String? _existingImageUrl;
  Uint8List? _selectedMobileImage;
  String? _existingMobileImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle ?? "");
    _subtitleCtrl = TextEditingController(text: widget.initialSubtitle ?? "");
    _existingImageUrl = widget.initialImageUrl;
    _existingMobileImageUrl = widget.initialMobileImageUrl;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isMobile) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      if (isMobile) {
        _selectedMobileImage = bytes;
        _existingMobileImageUrl = null;
      } else {
        _selectedImage = bytes;
        _existingImageUrl = null;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una imagen para el banner")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String imageUrl;
      if (_selectedImage != null) {
        final fileName =
            "banner_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final result = await _cloudinary.uploadImage(_selectedImage!, fileName);
        imageUrl = result["url"]!;
      } else {
        imageUrl = _existingImageUrl!;
      }

      String? mobileImageUrl = _existingMobileImageUrl;
      if (_selectedMobileImage != null) {
        final fileName =
            "banner_mobile_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final result = await _cloudinary.uploadImage(_selectedMobileImage!, fileName);
        mobileImageUrl = result["url"]!;
      }

      if (!mounted) return;
      final Map<String, dynamic> bannerData = {
        "imageUrl": imageUrl,
        "mobileImageUrl": mobileImageUrl,
        "title": _titleCtrl.text.trim(),
        "subtitle": _subtitleCtrl.text.trim(),
      };
      Navigator.of(context).pop(bannerData);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al subir imagen: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTitle != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? "Editar Banner" : "Nuevo Banner",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Los banners se muestran en el carrusel de la página principal.",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Imagen principal (Desktop)",
                              style: GoogleFonts.getFont(FontNames.fontNameH2,
                                  textStyle: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold))),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: _isSaving ? null : () => _pickImage(false),
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E2E2)),
                                color: Colors.grey[50],
                              ),
                              child: _buildImagePreview(false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Para móviles (Opcional)",
                              style: GoogleFonts.getFont(FontNames.fontNameH2,
                                  textStyle: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold))),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: _isSaving ? null : () => _pickImage(true),
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E2E2)),
                                color: Colors.grey[50],
                              ),
                              child: _buildImagePreview(true),
                            ),
                          ),
                          if (_selectedMobileImage != null || _existingMobileImageUrl != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _isSaving
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedMobileImage = null;
                                          _existingMobileImageUrl = null;
                                        });
                                      },
                                child: Text(
                                  "Quitar imagen",
                                  style: TextStyle(
                                      color: Colors.redAccent, fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _inputDecoration("Título del banner"),
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
                const SizedBox(height: 12),
                // Subtitle
                TextFormField(
                  controller: _subtitleCtrl,
                  decoration: _inputDecoration("Subtítulo del banner"),
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
                const SizedBox(height: 24),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancelar",
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? "Guardar" : "Crear Banner",
                              style:
                                  GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(bool isMobile) {
    if (isMobile) {
      if (_selectedMobileImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(_selectedMobileImage!, fit: BoxFit.cover),
        );
      }
      if (_existingMobileImageUrl != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(_existingMobileImageUrl!, fit: BoxFit.cover),
        );
      }
    } else {
      if (_selectedImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(_selectedImage!, fit: BoxFit.cover),
        );
      }
      if (_existingImageUrl != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
        );
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          "Click para seleccionar imagen",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
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
