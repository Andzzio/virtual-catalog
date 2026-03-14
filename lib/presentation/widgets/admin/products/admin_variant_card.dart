import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class AdminVariantCard extends StatefulWidget {
  final Map<String, dynamic> variant;
  final int index;
  final bool showDelete;
  final Function(int) onRemove;
  final Function(int, String, dynamic) onUpdate;
  const AdminVariantCard({
    super.key,
    required this.variant,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
    this.showDelete = true,
  });

  @override
  State<AdminVariantCard> createState() => _AdminVariantCardState();
}

class _AdminVariantCardState extends State<AdminVariantCard> {
  final TextEditingController _sizeCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE2E2E2)),
      ),
      child: Column(
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nombre",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.variant["name"],
                      decoration: _inputDecoration(
                        hintText: "ej. Camiseta Amarilla...",
                      ),
                      onChanged: (value) =>
                          widget.onUpdate(widget.index, "name", value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "El nombre es obligatorio";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SKU (Opcional)",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.variant["sku"],
                      decoration: _inputDecoration(
                        hintText: "ej. VC-001-VAR-001...",
                      ),

                      onChanged: (value) =>
                          widget.onUpdate(widget.index, "sku", value),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 1,
                child: widget.showDelete
                    ? IconButton(
                        onPressed: () => widget.onRemove(widget.index),
                        icon: Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 161, 161, 161),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(color: Color(0xFFE2E2E2)),
          SizedBox(height: 10),
          Row(
            spacing: 10,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Precio Original",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.variant["origPrice"],
                      decoration: _inputDecoration(hintText: "ej. 100.00..."),
                      onChanged: (value) =>
                          widget.onUpdate(widget.index, "origPrice", value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "El precio es obligatorio";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Descuento (Opcional)",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.variant["discountPrice"],
                      decoration: _inputDecoration(hintText: "ej. 80..."),
                      onChanged: (value) =>
                          widget.onUpdate(widget.index, "discountPrice", value),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Color",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _showColorPicker,
                      child: Container(
                        height: 48,
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: widget.variant["colorInt"] != null
                              ? Color(widget.variant["colorInt"])
                              : Colors.white,
                          border: Border.all(color: Color(0xffe2e2e2)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(color: Color(0xFFE2E2E2)),
          SizedBox(height: 10),
          Row(
            spacing: 10,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tallas",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _sizeCtrl,
                      decoration: _inputDecoration(
                        hintText: "Coloca UNA talla y presiona ENTER",
                      ),
                      onFieldSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          final dynamic rawSizes = widget.variant["sizes"];
                          List<String> currentSizes = (rawSizes is List)
                              ? List<String>.from(rawSizes)
                              : [];
                          currentSizes.add(value.trim());
                          widget.onUpdate(widget.index, "sizes", currentSizes);
                          _sizeCtrl.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Stock",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.variant["stock"],
                      decoration: _inputDecoration(hintText: "ej. 100..."),
                      onChanged: (value) =>
                          widget.onUpdate(widget.index, "stock", value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "El stock es obligatorio";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(widget.variant["sizes"].length, (index) {
              return InputChip(
                label: Text(
                  widget.variant["sizes"][index],
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 12),
                  ),
                ),
                onDeleted: () {
                  List<String> currentSizes = List<String>.from(
                    widget.variant["sizes"],
                  );
                  currentSizes.remove(widget.variant["sizes"][index]);
                  widget.onUpdate(widget.index, "sizes", currentSizes);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String hintText = ""}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.getFont(
        FontNames.fontNameH2,
        textStyle: TextStyle(color: Colors.grey),
      ),
      filled: true,
      fillColor: Color.fromARGB(255, 255, 255, 255),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE2E2E2)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showColorPicker() {
    Color pickerColor = widget.variant["colorInt"] != null
        ? Color(widget.variant["colorInt"])
        : Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(8),
        ),
        title: Text(
          "Selecciona el color",
          style: GoogleFonts.getFont(FontNames.fontNameH2),
        ),
        content: SingleChildScrollView(
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: TextTheme(
                bodyMedium: GoogleFonts.getFont(FontNames.fontNameH2),
                bodyLarge: GoogleFonts.getFont(FontNames.fontNameH2),
                bodySmall: GoogleFonts.getFont(FontNames.fontNameH2),
              ),
            ),
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (value) {
                pickerColor = value;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              "Cancelar",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onUpdate(widget.index, "colorInt", pickerColor.toARGB32());
              context.pop();
            },
            child: Text(
              "Seleccionar",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sizeCtrl.dispose();
    super.dispose();
  }
}
