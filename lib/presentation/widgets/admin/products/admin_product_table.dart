import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_image.dart';

class AdminProductTable extends StatefulWidget {
  const AdminProductTable({super.key});

  @override
  State<AdminProductTable> createState() => _AdminProductTableState();
}

class _AdminProductTableState extends State<AdminProductTable> {
  int currentPage = 0;
  int itemsPerPage = 10;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Material(
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: size.height * 0.65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFE2E2E2)),
        ),
        child: Consumer<ProductProvider>(
          builder: (context, value, child) {
            final products = value.products;
            final paginatedProducts = products
                .skip(currentPage * itemsPerPage)
                .take(itemsPerPage)
                .toList();
            if (value.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: DataTable(
                      showCheckboxColumn: false,
                      dataRowMinHeight: 65,
                      dataRowMaxHeight: 75,
                      headingRowColor: WidgetStateProperty.all(
                        Color(0xfff8f9fa),
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            "IMAGEN",
                            style: GoogleFonts.getFont(FontNames.fontNameH2),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "NOMBRE",
                            style: GoogleFonts.getFont(FontNames.fontNameH2),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "CATEGORÍA",
                            style: GoogleFonts.getFont(FontNames.fontNameH2),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "STOCK",
                            style: GoogleFonts.getFont(FontNames.fontNameH2),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "PRECIO",
                            style: GoogleFonts.getFont(FontNames.fontNameH2),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "ESTADO",
                            style: GoogleFonts.getFont(FontNames.fontNameH2),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "ACCIONES",
                            style: GoogleFonts.getFont(FontNames.fontNameH2),
                          ),
                        ),
                      ],
                      rows: paginatedProducts.map((product) {
                        return DataRow(
                          onSelectChanged: (value) {},
                          color: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.hovered)) {
                              return Colors.grey[50];
                            }
                            return null;
                          }),
                          cells: [
                            DataCell(
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CatalogImage(
                                  imageUrl: product.imageUrl.isNotEmpty
                                      ? product.imageUrl.first
                                      : "",
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                product.name,
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                product.category,
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                "${product.variants.fold(0, (sum, v) => sum + v.stock)}",
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                () {
                                  if (product.variants.isEmpty) {
                                    return "S/ 0.00";
                                  }
                                  final prices = product.variants.map(
                                    (v) => v.price,
                                  );
                                  final minPrice = prices.reduce(
                                    (value, element) =>
                                        value < element ? value : element,
                                  );
                                  final maxPrice = prices.reduce(
                                    (value, element) =>
                                        value > element ? value : element,
                                  );
                                  if (minPrice == maxPrice) {
                                    return "S/ ${minPrice.toStringAsFixed(2)}";
                                  }
                                  return "S/ ${minPrice.toStringAsFixed(2)} - ${maxPrice.toStringAsFixed(2)}";
                                }(),
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                ),
                              ),
                            ),
                            DataCell(
                              Switch(
                                value: product.isAvailable,
                                onChanged: null,
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.edit, size: 20),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Spacer(),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        "Mostrando ${currentPage * itemsPerPage + 1} - ${(currentPage * itemsPerPage + paginatedProducts.length)}  de ${products.length} productos",
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                      Spacer(),
                      OutlinedButton(
                        onPressed: currentPage > 0
                            ? () => setState(() => currentPage--)
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          side: BorderSide(color: Color(0xFFE2E2E2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                        child: Text(
                          "Anterior",
                          style: GoogleFonts.getFont(FontNames.fontNameH2),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            (currentPage + 1) * itemsPerPage < products.length
                            ? () => setState(() => currentPage++)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                        child: Text(
                          "Siguiente",
                          style: GoogleFonts.getFont(FontNames.fontNameH2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
