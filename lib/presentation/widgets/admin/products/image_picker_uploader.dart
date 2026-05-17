import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class ImagePickerUploader extends StatefulWidget {
  final List<dynamic> mediaItems; // Can be String (URL) or Uint8List (Bytes)
  final Function(List<dynamic>) onMediaChanged;
  const ImagePickerUploader({
    super.key,
    required this.mediaItems,
    required this.onMediaChanged,
  });

  @override
  State<ImagePickerUploader> createState() => _ImagePickerUploaderState();
}

class _ImagePickerUploaderState extends State<ImagePickerUploader> {
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Upload Button ─────────────────────────────
          InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AdminTheme.inputFill,
                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                border: Border.all(color: AdminTheme.border, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: AdminTheme.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "SUBIR",
                    style: AdminTheme.body().copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // ── Image List ────────────────────────────────
          Expanded(
            child: SelectionContainer.disabled(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  itemCount: widget.mediaItems.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final List<dynamic> updatedItems = List.from(
                        widget.mediaItems,
                      );
                      final item = updatedItems.removeAt(oldIndex);
                      updatedItems.insert(newIndex, item);
                      widget.onMediaChanged(updatedItems);
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = widget.mediaItems[index];
                    final isExisting = item is String;

                    return Container(
                      key: ValueKey("media_${item.hashCode}_$index"),
                      width: 120,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AdminTheme.radiusMd,
                        ),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image(
                              image: isExisting
                                  ? NetworkImage(item) as ImageProvider
                                  : MemoryImage(item as Uint8List),
                              fit: BoxFit.cover,
                            ),
                          ),
                          // ── Actions Overlay ──────────────
                          Positioned(
                            top: 6,
                            right: 6,
                            child: _buildActionBtn(
                              icon: Icons.close,
                              color: AdminTheme.danger,
                              onTap: () => _removeImage(index),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: ReorderableDragStartListener(
                              index: index,
                              child: _buildActionBtn(
                                icon: Icons.drag_indicator,
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AdminTheme.surface.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        List<dynamic> newMedia = List.from(widget.mediaItems);
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();
          newMedia.add(bytes);
        }
        if (!mounted) return;
        widget.onMediaChanged(newMedia);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error seleccionando imágenes: $e")),
        );
      }
    }
  }

  void _removeImage(int index) {
    List<dynamic> newMedia = List.from(widget.mediaItems);
    newMedia.removeAt(index);
    widget.onMediaChanged(newMedia);
  }
}
