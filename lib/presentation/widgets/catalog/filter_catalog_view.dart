import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/filter_catalog_provider.dart';

class FilterCatalogView extends StatefulWidget {
  const FilterCatalogView({super.key});

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
    final FilterCatalogProvider filterCatalogProvider = context
        .watch<FilterCatalogProvider>();
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
                    filterCatalogProvider.clearFilters();
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
                        filterCatalogProvider.selectedOrder,
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
                        filterCatalogProvider.selectOrder("Relevantes");
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
                        filterCatalogProvider.selectOrder("Mayor precio");
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
                        filterCatalogProvider.selectOrder("Menor Precio");
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
                  children: List.generate(
                    filterCatalogProvider.categories.length,
                    (index) {
                      return TextButton(
                        onPressed: () {
                          filterCatalogProvider.selectCategory(
                            filterCatalogProvider.categories[index],
                          );
                        },
                        child: Text(
                          filterCatalogProvider.categories[index],
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  filterCatalogProvider.categories[index] ==
                                      filterCatalogProvider.selectedCategory
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
                          filterCatalogProvider.setMinPrice(value);
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
                          filterCatalogProvider.setMaxPrice(value);
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
                  children: List.generate(filterCatalogProvider.sizes.length, (
                    index,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 10),
                      child: FilterChip(
                        selected: filterCatalogProvider.selectedSizes.contains(
                          filterCatalogProvider.sizes[index],
                        ),
                        selectedColor: Colors.black,
                        checkmarkColor: Colors.white,
                        label: Text(
                          filterCatalogProvider.sizes[index],
                          style: GoogleFonts.getFont(
                            FontNames.fontNameP,
                            textStyle: TextStyle(
                              color:
                                  filterCatalogProvider.selectedSizes.contains(
                                    filterCatalogProvider.sizes[index],
                                  )
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        onSelected: (_) {
                          filterCatalogProvider.toggleSize(
                            filterCatalogProvider.sizes[index],
                          );
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
                  value: filterCatalogProvider.isAvailable,
                  onChanged: (_) {
                    filterCatalogProvider.toggleAvailable();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FilterCatalogProvider>().clearFilters();
    });
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
