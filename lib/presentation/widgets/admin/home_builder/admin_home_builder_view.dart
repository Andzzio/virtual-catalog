import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/home_builder/admin_home_block_dialog.dart';

class AdminHomeBuilderView extends StatefulWidget {
  final String businessSlug;
  const AdminHomeBuilderView({super.key, required this.businessSlug});

  @override
  State<AdminHomeBuilderView> createState() => _AdminHomeBuilderViewState();
}

class _AdminHomeBuilderViewState extends State<AdminHomeBuilderView> {
  bool _isSaving = false;

  Future<void> _saveBlocks(List<HomeBlock> newBlocks) async {
    final business = context.read<BusinessProvider>().business;
    if (business == null) return;

    setState(() => _isSaving = true);
    
    final updated = Business(
      slug: business.slug,
      ownerId: business.ownerId,
      name: business.name,
      description: business.description,
      logoUrl: business.logoUrl,
      whatsappNumber: business.whatsappNumber,
      banners: business.banners,
      deliveryMethods: business.deliveryMethods,
      paymentMethods: business.paymentMethods,
      showDesktopLogo: business.showDesktopLogo,
      showMobileLogo: business.showMobileLogo,
      termsAndConditions: business.termsAndConditions,
      homeBlocks: newBlocks,
    );

    try {
      await context.read<BusinessProvider>().updateBusiness(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Orden guardado")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showBlockDialog([HomeBlock? block, int? index]) {
    final business = context.read<BusinessProvider>().business;
    if (business == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AdminHomeBlockDialog(
        initialBlock: block,
        onSave: (newBlock) {
          final currentBlocks = List<HomeBlock>.from(business.homeBlocks);
          if (index != null) {
            currentBlocks[index] = newBlock;
          } else {
            currentBlocks.add(newBlock);
          }
          _saveBlocks(currentBlocks);
        },
      ),
    );
  }

  void _deleteBlock(int index) {
    final business = context.read<BusinessProvider>().business;
    if (business == null) return;

    final currentBlocks = List<HomeBlock>.from(business.homeBlocks);
    currentBlocks.removeAt(index);
    _saveBlocks(currentBlocks);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    final business = provider.business;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }
    if (business == null) {
      return const Center(child: Text("No se pudo cargar el negocio."));
    }

    final blocks = business.homeBlocks;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E2E2), height: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Diseño del Home",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "Ordena y edita los bloques que aparecen en la página principal.",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBlockDialog(),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          "Añadir Bloque",
          style: GoogleFonts.getFont(FontNames.fontNameH2),
        ),
      ),
      body: blocks.isEmpty
          ? Center(
              child: Text(
                "No hay bloques creados. El Home está vacío.",
                style: GoogleFonts.getFont(FontNames.fontNameH2),
              ),
            )
          : Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.transparent,
              ),
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                itemCount: blocks.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final currentBlocks = List<HomeBlock>.from(blocks);
                  final item = currentBlocks.removeAt(oldIndex);
                  currentBlocks.insert(newIndex, item);
                  _saveBlocks(currentBlocks);
                },
                itemBuilder: (context, index) {
                  final block = blocks[index];
                  return Card(
                    key: ValueKey(block.id),
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFE2E2E2)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          block.layout == BlockLayout.grid
                              ? Icons.grid_view
                              : Icons.view_list_rounded,
                          color: Colors.black87,
                        ),
                      ),
                      title: Text(
                        block.title,
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Text(
                        "${_getLayoutName(block.layout)} • ${_getSortName(block.sortCriteria)} • Límite: ${block.itemsLimit}",
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () => _showBlockDialog(block, index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteBlock(index),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.drag_handle, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _getLayoutName(BlockLayout layout) {
    switch (layout) {
      case BlockLayout.list:
        return "Carrusel";
      case BlockLayout.grid:
        return "Grilla";
      case BlockLayout.mosaic:
        return "Mosaico Destacado";
      case BlockLayout.featured:
        return "Producto Estrella";
    }
  }

  String _getSortName(BlockSortCriteria criteria) {
    switch (criteria) {
      case BlockSortCriteria.newest:
        return "Nuevos Ingresos";
      case BlockSortCriteria.bestSelling:
        return "Más Vendidos";
      case BlockSortCriteria.recentlyUpdated:
        return "Recién Actualizados";
      case BlockSortCriteria.alphabetical:
        return "Alfabético";
      case BlockSortCriteria.biggestDiscount:
        return "Liquidación";
      case BlockSortCriteria.premiumFirst:
        return "Premium";
      case BlockSortCriteria.affordableFirst:
        return "Ofertas Rápidas";
      case BlockSortCriteria.manual:
        return "Selección Manual";
    }
  }
}
