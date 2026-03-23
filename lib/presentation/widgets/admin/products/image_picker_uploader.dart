import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class ImagePickerUploader extends StatefulWidget {
  final List<Uint8List> images;
  final Function(List<Uint8List>) onImagesChanged;
  final List<String> existingUrls;
  final Function(List<String>)? onExistingUrlsChanged;
  const ImagePickerUploader({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.existingUrls = const [],
    this.onExistingUrlsChanged,
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.existingUrls.length + widget.images.length,
                  itemBuilder: (context, index) {
                    final isExisting = index < widget.existingUrls.length;
                    return Container(
                      key: ValueKey(isExisting
                          ? "url_$index"
                          : "img_${index - widget.existingUrls.length}"),
                      width: 120,
                      margin: EdgeInsets.only(right: 15),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Color(0xffe2e2e2)),
                                image: DecorationImage(
                                  image: isExisting
                                      ? NetworkImage(
                                              widget.existingUrls[index])
                                          as ImageProvider
                                      : MemoryImage(widget.images[
                                          index -
                                              widget.existingUrls.length]),
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
                                if (isExisting) {
                                  _removeExistingUrl(index);
                                } else {
                                  _removeImage(
                                      index - widget.existingUrls.length);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    232, 255, 255, 255),
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
        List<Uint8List> newImages = List.from(widget.images);
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();
          newImages.add(bytes);
        }
        widget.onImagesChanged(newImages);
      }
    } catch (e) {
      debugPrint("Error seleccionando imagenes: \$e");
    }
  }

  void _removeImage(int index) {
    List<Uint8List> newImages = List.from(widget.images);
    newImages.removeAt(index);
    widget.onImagesChanged(newImages);
  }

  void _removeExistingUrl(int index) {
    if (widget.onExistingUrlsChanged != null) {
      List<String> newUrls = List.from(widget.existingUrls);
      newUrls.removeAt(index);
      widget.onExistingUrlsChanged!(newUrls);
    }
  }
}
