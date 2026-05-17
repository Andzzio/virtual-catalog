import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/data/services/cloudinary_service.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

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
        final result =
            await _cloudinary.uploadImage(_selectedImage!, fileName);
        imageUrl = result["url"]!;
      } else {
        imageUrl = _existingImageUrl!;
      }

      String? mobileImageUrl = _existingMobileImageUrl;
      if (_selectedMobileImage != null) {
        final fileName =
            "banner_mobile_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final result =
            await _cloudinary.uploadImage(_selectedMobileImage!, fileName);
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

    // Skill: Use Dialog with scroll to prevent overflow on small screens
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTheme.radiusLg)),
      backgroundColor: AdminTheme.cardBg,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header ─────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AdminTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? "Editar Banner" : "Nuevo Banner",
                          style: AdminTheme.heading2(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Se mostrará en el carrusel de la página principal.",
                          style: AdminTheme.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // ─── Body (scrollable) ──────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image pickers — responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 400;
                          final desktopPicker = _buildImagePicker(
                            label: "Desktop",
                            isMobile: false,
                          );
                          final mobilePicker = _buildImagePicker(
                            label: "Móvil (Opcional)",
                            isMobile: true,
                          );

                          if (isNarrow) {
                            return Column(
                              children: [
                                desktopPicker,
                                const SizedBox(height: 12),
                                mobilePicker,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: desktopPicker),
                              const SizedBox(width: 16),
                              Expanded(child: mobilePicker),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text("Título", style: AdminTheme.body().copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: AdminTheme.inputDecoration(hintText: "Ej: Nueva Colección"),
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                      const SizedBox(height: 16),
                      // Subtitle
                      Text("Subtítulo", style: AdminTheme.body().copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _subtitleCtrl,
                        decoration: AdminTheme.inputDecoration(hintText: "Ej: Temporada Otoño 2025"),
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Footer Actions ─────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AdminTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      style: AdminTheme.outlinedButton(),
                      child: Text("Cancelar", style: GoogleFonts.getFont(FontNames.fontNameH2)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: AdminTheme.primaryButton(),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? "Guardar" : "Crear Banner",
                              style: GoogleFonts.getFont(FontNames.fontNameH2)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker({required String label, required bool isMobile}) {
    final hasImage = isMobile
        ? (_selectedMobileImage != null || _existingMobileImageUrl != null)
        : (_selectedImage != null || _existingImageUrl != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AdminTheme.body().copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _isSaving ? null : () => _pickImage(isMobile),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              border: Border.all(
                color: hasImage ? AdminTheme.border : AdminTheme.textMuted,
                width: hasImage ? 1 : 1.5,
              ),
              color: AdminTheme.surface,
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImagePreview(isMobile),
          ),
        ),
        if (isMobile && hasImage)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isSaving
                  ? null
                  : () => setState(() {
                        _selectedMobileImage = null;
                        _existingMobileImageUrl = null;
                      }),
              child: Text("Quitar",
                  style: TextStyle(color: AdminTheme.danger, fontSize: 12)),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview(bool isMobile) {
    if (isMobile) {
      if (_selectedMobileImage != null) {
        return Image.memory(_selectedMobileImage!, fit: BoxFit.cover, width: double.infinity);
      }
      if (_existingMobileImageUrl != null) {
        return Image.network(_existingMobileImageUrl!, fit: BoxFit.cover, width: double.infinity);
      }
    } else {
      if (_selectedImage != null) {
        return Image.memory(_selectedImage!, fit: BoxFit.cover, width: double.infinity);
      }
      if (_existingImageUrl != null) {
        return Image.network(_existingImageUrl!, fit: BoxFit.cover, width: double.infinity);
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 32, color: AdminTheme.textMuted),
        const SizedBox(height: 6),
        Text("Toca para subir", style: AdminTheme.caption()),
      ],
    );
  }
}
