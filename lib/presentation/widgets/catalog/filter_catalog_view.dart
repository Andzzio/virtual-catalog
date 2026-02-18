import 'package:flutter/material.dart';
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
                IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Precio",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tallas",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(fontSize: 15),
                  ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
