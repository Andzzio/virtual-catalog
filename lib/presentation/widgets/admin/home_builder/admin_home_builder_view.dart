import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Orden guardado")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
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
      return const Center(
        child: CircularProgressIndicator(color: AdminTheme.accent),
      );
    }
    if (business == null) {
      return const Center(child: Text("No se pudo cargar el negocio."));
    }

    final blocks = business.homeBlocks;

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.cardBg,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AdminTheme.border, height: 1.0),
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
              "Mantén presionado y arrastra o usa las flechas para reordenar.",
              style: AdminTheme.bodySmall(),
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AdminTheme.accent,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBlockDialog(),
        backgroundColor: AdminTheme.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          "Añadir Sección",
          style: GoogleFonts.getFont(FontNames.fontNameH2),
        ),
      ),
      body: blocks.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPad =
                    constraints.maxWidth < AdminTheme.breakpointMobile
                    ? 16.0
                    : 40.0;

                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(canvasColor: Colors.transparent),
                  child: ReorderableListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPad,
                      vertical: 20,
                    ),
                    buildDefaultDragHandles: false, // Custom handle only
                    itemCount: blocks.length,
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex < newIndex) newIndex -= 1;
                      final currentBlocks = List<HomeBlock>.from(blocks);
                      final item = currentBlocks.removeAt(oldIndex);
                      currentBlocks.insert(newIndex, item);
                      _saveBlocks(currentBlocks);
                    },
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      return _buildBlockCard(block, index, blocks.length);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _moveBlock(int index, int delta) {
    final business = context.read<BusinessProvider>().business;
    if (business == null) return;

    final currentBlocks = List<HomeBlock>.from(business.homeBlocks);
    final targetIndex = index + delta;
    if (targetIndex < 0 || targetIndex >= currentBlocks.length) return;

    final item = currentBlocks.removeAt(index);
    currentBlocks.insert(targetIndex, item);
    _saveBlocks(currentBlocks);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 64,
            color: AdminTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            "Tu página principal está vacía",
            style: AdminTheme.heading2().copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Añade secciones para mostrar productos a tus clientes.",
            style: AdminTheme.bodySmall(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockCard(HomeBlock block, int index, int totalCount) {
    final layoutName = _getLayoutName(block.layout);
    final sortName = _getSortName(block.sortCriteria);
    final layoutIcon = block.layout == BlockLayout.grid
        ? Icons.grid_view
        : block.layout == BlockLayout.mosaic
        ? Icons.view_quilt_outlined
        : block.layout == BlockLayout.featured
        ? Icons.star_outline
        : Icons.view_list_rounded;

    return Container(
      key: ValueKey(block.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AdminTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Row 1: Icon + Title + Handle
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminTheme.surface,
                    borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
                  ),
                  child: Icon(layoutIcon, color: AdminTheme.accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    block.title,
                    style: AdminTheme.body().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.drag_indicator,
                      color: AdminTheme.textMuted,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Row 2: Tags + Move Arrows + Actions
            Row(
              children: [
                // Tags
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildTag(Icons.dashboard_outlined, layoutName),
                      _buildTag(Icons.sort, sortName),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Simplified UX: Up/Down Arrows
                if (totalCount > 1) ...[
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_upward, size: 18),
                    onPressed: index == 0 ? null : () => _moveBlock(index, -1),
                    tooltip: "Subir",
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_downward, size: 18),
                    onPressed: index == totalCount - 1
                        ? null
                        : () => _moveBlock(index, 1),
                    tooltip: "Bajar",
                  ),
                ],
                // Actions
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showBlockDialog(block, index),
                  tooltip: "Editar",
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AdminTheme.danger,
                  ),
                  onPressed: () => _deleteBlock(index),
                  tooltip: "Eliminar",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AdminTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AdminTheme.caption().copyWith(fontSize: 11)),
        ],
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
        return "Mosaico";
      case BlockLayout.featured:
        return "Estrella";
    }
  }

  String _getSortName(BlockSortCriteria criteria) {
    switch (criteria) {
      case BlockSortCriteria.newest:
        return "Nuevos";
      case BlockSortCriteria.bestSelling:
        return "Más Vendidos";
      case BlockSortCriteria.recentlyUpdated:
        return "Actualizados";
      case BlockSortCriteria.alphabetical:
        return "Alfabético";
      case BlockSortCriteria.biggestDiscount:
        return "Liquidación";
      case BlockSortCriteria.premiumFirst:
        return "Premium";
      case BlockSortCriteria.affordableFirst:
        return "Ofertas";
      case BlockSortCriteria.manual:
        return "Manual";
    }
  }
}
