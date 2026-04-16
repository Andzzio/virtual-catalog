import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

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
          InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "SUBIR",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15),
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
                  buildDefaultDragHandles: false, // We will provide our own drag handle
                  itemCount: widget.mediaItems.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final List<dynamic> updatedItems = List.from(widget.mediaItems);
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
                      margin: EdgeInsets.only(right: 15),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xffe2e2e2)),
                                image: DecorationImage(
                                  image: isExisting
                                      ? NetworkImage(item) as ImageProvider
                                      : MemoryImage(item as Uint8List),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: InkWell(
                              onTap: () {
                                _removeImage(index);
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(232, 255, 255, 255),
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(blurRadius: 4)],
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: ReorderableDragStartListener(
                              index: index,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(232, 255, 255, 255),
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(blurRadius: 4)],
                                ),
                                child: Icon(
                                  Icons.drag_indicator,
                                  size: 16,
                                  color: Colors.black87,
                                ),
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

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        List<dynamic> newMedia = List.from(widget.mediaItems);
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();
          newMedia.add(bytes);
        }
        widget.onMediaChanged(newMedia);
      }
    } catch (e) {
      debugPrint("Error seleccionando imagenes: $e");
    }
  }

  void _removeImage(int index) {
    List<dynamic> newMedia = List.from(widget.mediaItems);
    newMedia.removeAt(index);
    widget.onMediaChanged(newMedia);
  }
}
