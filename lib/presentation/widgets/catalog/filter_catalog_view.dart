import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/utils/filter_catalog.dart';

class FilterCatalogView extends StatefulWidget {
  final String slug;
  final String? search;
  final String selectedCategory;
  final String selectedOrder;
  final double minPrice;
  final double maxPrice;
  final Set<String> selectedSizes;
  final bool isAvailable;
  final List<String> categories;
  final List<String> sizes;
  const FilterCatalogView({
    super.key,
    required this.slug,
    this.search,
    required this.selectedCategory,
    required this.selectedOrder,
    required this.minPrice,
    required this.maxPrice,
    required this.selectedSizes,
    required this.isAvailable,
    required this.categories,
    required this.sizes,
  });

  @override
  State<FilterCatalogView> createState() => _FilterCatalogViewState();
}

class _FilterCatalogViewState extends State<FilterCatalogView> {
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  final FocusNode _minFocusNode = FocusNode();
  final FocusNode _maxFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filtros",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 20),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final url = "/${widget.slug}/catalog";
                    final route = ModalRoute.of(context);
                    if (route != null && route is PopupRoute) {
                      Navigator.of(context).pop(url);
                    } else {
                      context.go(url);
                    }
                    if (_minController.text.isNotEmpty) {
                      _minController.clear();
                    }
                    if (_maxController.text.isNotEmpty) {
                      _maxController.clear();
                    }
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ordernar por:",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 15),
                  ),
                ),
                MenuAnchor(
                  builder: (context, controller, child) {
                    return TextButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      child: Text(
                        widget.selectedOrder,
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                    );
                  },
                  menuChildren: [
                    MenuItemButton(
                      child: Text(
                        "Relevantes",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                      onPressed: () {
                        return _replaceUrl(sort: "Relevantes");
                      },
                    ),
                    MenuItemButton(
                      child: Text(
                        "Mayor precio",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                      onPressed: () {
                        return _replaceUrl(sort: "Mayor Precio");
                      },
                    ),
                    MenuItemButton(
                      child: Text(
                        "Menor Precio",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                      onPressed: () {
                        return _replaceUrl(sort: "Menor Precio");
                      },
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Categorías",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 15),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(widget.categories.length, (index) {
                    return TextButton(
                      onPressed: () {
                        return _replaceUrl(category: widget.categories[index]);
                      },
                      child: Text(
                        widget.categories[index],
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                widget.categories[index] ==
                                    widget.selectedCategory
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Precio",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minController,
                        focusNode: _minFocusNode,
                        style: GoogleFonts.getFont(FontNames.fontNameP),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixText: "S/. ",
                          prefixStyle: GoogleFonts.getFont(FontNames.fontNameP),
                          hintText: "Min",
                          hintStyle: GoogleFonts.getFont(FontNames.fontNameP),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onEditingComplete: () {
                          final value =
                              double.tryParse(_minController.text) ?? 0;
                          _replaceUrl(minPrice: value);
                          if (_minController.text.isNotEmpty &&
                              _maxController.text.isEmpty) {
                            _maxFocusNode.requestFocus();
                          } else {
                            _minFocusNode.unfocus();
                            _maxFocusNode.unfocus();
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(width: 20, child: Divider()),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _maxController,
                        focusNode: _maxFocusNode,
                        style: GoogleFonts.getFont(FontNames.fontNameP),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixText: "S/. ",
                          prefixStyle: GoogleFonts.getFont(FontNames.fontNameP),
                          hintText: "Max",
                          hintStyle: GoogleFonts.getFont(FontNames.fontNameP),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onEditingComplete: () {
                          final value =
                              double.tryParse(_maxController.text) ?? 0;
                          _replaceUrl(maxPrice: value);
                          if (_maxController.text.isNotEmpty &&
                              _minController.text.isEmpty) {
                            _minFocusNode.requestFocus();
                          } else {
                            _minFocusNode.unfocus();
                            _maxFocusNode.unfocus();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tallas",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  children: List.generate(widget.sizes.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 10),
                      child: FilterChip(
                        selected: widget.selectedSizes.contains(
                          widget.sizes[index],
                        ),
                        selectedColor: Colors.black,
                        checkmarkColor: Colors.white,
                        label: Text(
                          widget.sizes[index],
                          style: GoogleFonts.getFont(
                            FontNames.fontNameP,
                            textStyle: TextStyle(
                              color:
                                  widget.selectedSizes.contains(
                                    widget.sizes[index],
                                  )
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        onSelected: (_) {
                          final newSizes = Set<String>.from(
                            widget.selectedSizes,
                          );
                          if (newSizes.contains(widget.sizes[index])) {
                            newSizes.remove(widget.sizes[index]);
                          } else {
                            newSizes.add(widget.sizes[index]);
                          }
                          _replaceUrl(sizes: newSizes);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Solo en stock",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 15),
                  ),
                ),
                Checkbox(
                  activeColor: Colors.black,
                  side: BorderSide(color: Colors.grey),
                  value: widget.isAvailable,
                  onChanged: (_) {
                    _replaceUrl(available: !widget.isAvailable);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _replaceUrl({
    String? search,
    String? category,
    String? sort,
    double? minPrice,
    double? maxPrice,
    Set<String>? sizes,
    bool? available,
  }) {
    final url = FilterCatalog.buildCatalogUrl(
      widget.slug,
      search: search ?? widget.search,
      category: category ?? widget.selectedCategory,
      sort: sort ?? widget.selectedOrder,
      minPrice: minPrice ?? widget.minPrice,
      maxPrice: maxPrice ?? widget.maxPrice,
      sizes: sizes ?? widget.selectedSizes,
      available: available ?? widget.isAvailable,
    );
    
    final route = ModalRoute.of(context);
    if (route != null && route is PopupRoute) {
      Navigator.of(context).pop(url);
    } else {
      context.go(url);
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _minFocusNode.dispose();
    _maxFocusNode.dispose();
    super.dispose();
  }
}
