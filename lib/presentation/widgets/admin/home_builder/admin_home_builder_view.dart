import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/home_block.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'package:virtual_catalog_app/presentation/widgets/product/home_block_renderer.dart';

class AdminHomeBuilderView extends StatefulWidget {
  final String businessSlug;
  const AdminHomeBuilderView({super.key, required this.businessSlug});

  @override
  State<AdminHomeBuilderView> createState() => _AdminHomeBuilderViewState();
}

class _AdminHomeBuilderViewState extends State<AdminHomeBuilderView> {
  bool _isSaving = false;
  bool _showEditor = false;
  HomeBlock? _editingBlock;
  int? _editingIndex;
  int _activeStepIndex = 1;
  bool _hasSelectedLayout = false;
  bool _hasInteractedWithStep3 = false;
  BlockLayout? _hoveredLayout;
  final _step1Key = GlobalKey();
  final _step2Key = GlobalKey();
  final _step3Key = GlobalKey();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late TextEditingController _buttonTextCtrl;
  late ScrollController _scrollCtrl;

  BlockLayout? _selectedLayout;
  BlockSortCriteria? _selectedCriteria;
  int _selectedLimit = 10;
  String? _selectedSpecificProductId;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _subtitleCtrl = TextEditingController();
    _buttonTextCtrl = TextEditingController(text: "Ver todos");
    _scrollCtrl = ScrollController();
    _titleCtrl.addListener(_onTextChanged);
    _subtitleCtrl.addListener(_onTextChanged);
    _buttonTextCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _buttonTextCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  Future<void> _saveBlocks(List<HomeBlock> newBlocks) async {
    final business = context.read<BusinessProvider>().business;
    if (business == null) return;

    setState(() => _isSaving = true);

    final updated = business.copyWith(homeBlocks: newBlocks);

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

  void _openEditor([HomeBlock? block, int? index]) {
    setState(() {
      _activeStepIndex = 1;
      _hasSelectedLayout = block != null;
      _hasInteractedWithStep3 = block != null;
      _showEditor = true;
      _editingBlock = block;
      _editingIndex = index;
      if (block != null) {
        _titleCtrl.text = block.title;
        _subtitleCtrl.text = block.subtitle ?? "";
        _selectedLayout = block.layout;
        _selectedCriteria = block.sortCriteria;
        _selectedLimit = block.itemsLimit;
        _selectedSpecificProductId = block.specificProductId;
        _showButton = block.showButton;
        _buttonTextCtrl.text = block.buttonText ?? "Ver todos";
      } else {
        _titleCtrl.clear();
        _subtitleCtrl.clear();
        _selectedLayout = null;
        _selectedCriteria = null;
        _selectedLimit = 10;
        _selectedSpecificProductId = null;
        _showButton = false;
        _buttonTextCtrl.text = "Ver todos";
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  void _cancelEditor() {
    setState(() {
      _showEditor = false;
      _editingBlock = null;
      _editingIndex = null;
    });
  }

  void _submitEditor() {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() {
        _activeStepIndex = 1;
      });
      _formKey.currentState!.validate();
      final ctx = _step1Key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      return;
    }
    if (_selectedLayout == null) {
      setState(() {
        _activeStepIndex = 2;
      });
      final ctx = _step2Key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecciona un diseño en el Paso 2")),
      );
      return;
    }
    if (_selectedCriteria == null) {
      setState(() {
        _activeStepIndex = 3;
      });
      final ctx = _step3Key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecciona un criterio en el Paso 3")),
      );
      return;
    }
    if (_selectedCriteria == BlockSortCriteria.manual && _selectedSpecificProductId == null) {
      setState(() {
        _activeStepIndex = 3;
      });
      _formKey.currentState!.validate();
      final ctx = _step3Key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    final business = context.read<BusinessProvider>().business;
    if (business == null) return;

    final limit = _selectedLayout == BlockLayout.featured
        ? 1
        : (_selectedLayout == BlockLayout.mosaic ? 3 : _selectedLimit);

    final newBlock = HomeBlock(
      id: _editingBlock?.id ?? "block_${DateTime.now().millisecondsSinceEpoch}",
      layout: _selectedLayout!,
      title: _titleCtrl.text.trim(),
      subtitle: _subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim(),
      showButton: _showButton,
      buttonText: _showButton && _buttonTextCtrl.text.trim().isNotEmpty
          ? _buttonTextCtrl.text.trim()
          : null,
      sortCriteria: _selectedCriteria!,
      itemsLimit: limit,
      specificProductId: _selectedCriteria == BlockSortCriteria.manual
          ? _selectedSpecificProductId
          : null,
    );

    final currentBlocks = List<HomeBlock>.from(business.homeBlocks);
    if (_editingIndex != null) {
      currentBlocks[_editingIndex!] = newBlock;
    } else {
      currentBlocks.add(newBlock);
    }

    _saveBlocks(currentBlocks);
    setState(() {
      _showEditor = false;
    });
  }

  void _deleteBlock(int index) {
    final business = context.read<BusinessProvider>().business;
    if (business == null) return;

    final currentBlocks = List<HomeBlock>.from(business.homeBlocks);
    currentBlocks.removeAt(index);
    _saveBlocks(currentBlocks);
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

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    if (_selectedCriteria == null) return [];
    var filtered = List<Product>.from(allProducts);
    if (_selectedCriteria == BlockSortCriteria.manual) {
      if (_selectedSpecificProductId != null) {
        filtered = filtered.where((p) => p.id == _selectedSpecificProductId).toList();
      } else {
        filtered = [];
      }
    } else {
      switch (_selectedCriteria) {
        case BlockSortCriteria.newest:
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case BlockSortCriteria.bestSelling:
          break;
        case BlockSortCriteria.recentlyUpdated:
          filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          break;
        case BlockSortCriteria.alphabetical:
          filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case BlockSortCriteria.premiumFirst:
          filtered.sort((a, b) {
            final priceA = a.variants.isNotEmpty ? a.variants.first.price : 0.0;
            final priceB = b.variants.isNotEmpty ? b.variants.first.price : 0.0;
            return priceB.compareTo(priceA);
          });
          break;
        case BlockSortCriteria.affordableFirst:
          filtered.sort((a, b) {
            final priceA = a.variants.isNotEmpty ? a.variants.first.price : 0.0;
            final priceB = b.variants.isNotEmpty ? b.variants.first.price : 0.0;
            return priceA.compareTo(priceB);
          });
          break;
        case BlockSortCriteria.biggestDiscount:
          filtered.sort((a, b) {
            final discA = a.variants.isNotEmpty ? (a.variants.first.price - (a.variants.first.discountPrice ?? 0.0)) : 0.0;
            final discB = b.variants.isNotEmpty ? (b.variants.first.price - (b.variants.first.discountPrice ?? 0.0)) : 0.0;
            return discB.compareTo(discA);
          });
          break;
        default:
          break;
      }
    }
    final limit = _selectedLayout == BlockLayout.featured
        ? 1
        : (_selectedLayout == BlockLayout.mosaic ? 3 : _selectedLimit);
    return filtered.take(limit).toList();
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
        backgroundColor: AdminTheme.sidebarBg,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white.withValues(alpha: 0.08), height: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _showEditor
                  ? (_editingBlock != null ? "Editar Sección" : "Nueva Sección")
                  : "Diseño del Home",
              style: AdminTheme.appBarTitle(),
            ),
            Text(
              _showEditor
                  ? (_editingBlock != null
                      ? "Modifica los detalles de la sección del home."
                      : "Configura una nueva sección para tu página principal.")
                  : "Arrastra para reordenar. Los cambios se ven en tiempo real en tu tienda.",
              style: AdminTheme.appBarSubtitle(),
            ),
          ],
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
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
          if (!_showEditor)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: ElevatedButton.icon(
                onPressed: () => _openEditor(),
                style: AdminTheme.primaryButton().copyWith(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  "Añadir sección",
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                onPressed: _cancelEditor,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: "Volver a la lista",
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _showEditor
            ? SingleChildScrollView(
                key: const ValueKey("editor_view"),
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                child: _buildEditorInline(context),
              )
            : SingleChildScrollView(
                key: const ValueKey("list_view"),
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (blocks.isNotEmpty) ...[
                      Theme(
                        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: blocks.length,
                          onReorderItem: (oldIndex, newIndex) {
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
                      ),
                    ] else ...[
                      _buildEmptyState(),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard_customize_outlined,
              size: 64,
              color: AdminTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              "Tu página principal está vacía",
              style: AdminTheme.heading2(),
            ),
            const SizedBox(height: 8),
            Text(
              "Añade secciones para mostrar productos a tus clientes.",
              style: AdminTheme.bodySmall(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockCard(HomeBlock block, int index, int totalCount) {
    final layoutName = _getLayoutName(block.layout);
    final sortName = _getSortName(block.sortCriteria);

    return Container(
      key: ValueKey(block.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AdminTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.drag_indicator,
                  color: AdminTheme.textMuted,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildMiniature(block.layout),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        block.title,
                        style: AdminTheme.body().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildLayoutBadge(layoutName),
                      const SizedBox(width: 6),
                      _buildCriteriaBadge(sortName),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    block.sortCriteria == BlockSortCriteria.manual
                        ? "1 producto seleccionado manualmente"
                        : "${block.subtitle ?? 'Orden automático'} · ${block.itemsLimit} productos",
                    style: AdminTheme.bodySmall(),
                  ),
                ],
              ),
            ),
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
              const SizedBox(width: 8),
            ],
            IconButton(
              onPressed: () => _openEditor(block, index),
              icon: const Icon(Icons.edit_outlined, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AdminTheme.surface,
                side: const BorderSide(color: AdminTheme.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _deleteBlock(index),
              icon: const Icon(Icons.delete_outline, color: AdminTheme.danger, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AdminTheme.danger.withValues(alpha: 0.1),
                side: const BorderSide(color: AdminTheme.danger),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AdminTheme.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AdminTheme.caption().copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildCriteriaBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Text(
        text,
        style: AdminTheme.caption().copyWith(
          color: AdminTheme.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildMiniature(BlockLayout layout) {
    Widget productsWidget;
    final primaryColor = AdminTheme.accent;
    final secondaryColor = AdminTheme.textSecondary;
    final mutedColor = AdminTheme.textMuted.withValues(alpha: 0.3);

    switch (layout) {
      case BlockLayout.list:
        productsWidget = Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: mutedColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        );
        break;
      case BlockLayout.grid:
        productsWidget = Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case BlockLayout.mosaic:
        productsWidget = Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case BlockLayout.featured:
        productsWidget = Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
        break;
    }

    return Container(
      width: 80,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AdminTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AdminTheme.sidebarBg,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(child: productsWidget),
        ],
      ),
    );
  }

  Widget _buildEditorInline(BuildContext context) {
    return Container(
      key: ValueKey(_editingBlock?.id ?? 'new_section_form'),
      padding: const EdgeInsets.all(24),
      decoration: AdminTheme.cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _buildStepsIndicator(),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 750;
                final leftColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStepLabel("1. NOMBRE DE LA SECCIÓN", key: _step1Key),
                    TextFormField(
                      controller: _titleCtrl,
                      style: AdminTheme.body(),
                      decoration: AdminTheme.inputDecoration(hintText: "Nombre de la sección"),
                      onTap: () => setState(() => _activeStepIndex = 1),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Requerido" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _subtitleCtrl,
                      style: AdminTheme.body(),
                      decoration: AdminTheme.inputDecoration(hintText: "Subtítulo (opcional)"),
                      onTap: () => setState(() => _activeStepIndex = 1),
                    ),
                    const SizedBox(height: 16),
                    _buildStepLabel("2. ¿CÓMO SE VE?", key: _step2Key),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.1,
                      children: [
                        _buildLayoutCard(
                          layout: BlockLayout.list,
                          name: "Carrusel",
                          desc: "Desliza",
                        ),
                        _buildLayoutCard(
                          layout: BlockLayout.grid,
                          name: "Cuadrícula",
                          desc: "Grilla",
                        ),
                        _buildLayoutCard(
                          layout: BlockLayout.mosaic,
                          name: "Destacado",
                          desc: "1 grande + 2 pequeños",
                        ),
                        _buildLayoutCard(
                          layout: BlockLayout.featured,
                          name: "Único",
                          desc: "Estrella",
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStepLabel("3. ¿QUÉ PRODUCTOS?", key: _step3Key),
                    if (_selectedLayout == null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AdminTheme.surface,
                          borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                          border: Border.all(color: AdminTheme.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AdminTheme.textMuted),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Selecciona un diseño primero en el Paso 2",
                                style: AdminTheme.bodySmall().copyWith(color: AdminTheme.textMuted),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      DropdownButtonFormField<BlockSortCriteria>(
                        dropdownColor: AdminTheme.cardBgElevated,
                        decoration: AdminTheme.inputDecoration(hintText: "Seleccionar criterio de ordenación"),
                        initialValue: _selectedCriteria,
                        style: AdminTheme.body(),
                        onTap: () => setState(() => _activeStepIndex = 3),
                        items: const [
                          DropdownMenuItem(
                            value: BlockSortCriteria.newest,
                            child: Text("🆕 Los más nuevos"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.bestSelling,
                            child: Text("🔥 Los más vendidos"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.biggestDiscount,
                            child: Text("💰 Mayor descuento"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.premiumFirst,
                            child: Text("💎 Precio alto primero"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.affordableFirst,
                            child: Text("🏷️ Precio bajo primero"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.recentlyUpdated,
                            child: Text("🔄 Actualizados recientemente"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.alphabetical,
                            child: Text("🔤 Orden alfabético"),
                          ),
                          DropdownMenuItem(
                            value: BlockSortCriteria.manual,
                            child: Text("👆 Elegir un producto específico"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _activeStepIndex = 3;
                              _hasInteractedWithStep3 = true;
                              _selectedCriteria = val;
                            });
                          }
                        },
                      ),
                      if (_selectedCriteria == BlockSortCriteria.manual) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          dropdownColor: AdminTheme.cardBgElevated,
                          decoration: AdminTheme.inputDecoration(hintText: "Seleccionar producto..."),
                          initialValue: _selectedSpecificProductId,
                          style: AdminTheme.body(),
                          onTap: () => setState(() => _activeStepIndex = 3),
                          items: context
                              .read<ProductProvider>()
                              .products
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _activeStepIndex = 3;
                              _hasInteractedWithStep3 = true;
                              _selectedSpecificProductId = val;
                            });
                          },
                          validator: (v) =>
                              v == null ? "Selecciona un producto" : null,
                        ),
                      ],
                      if (_selectedLayout != BlockLayout.featured &&
                          _selectedLayout != BlockLayout.mosaic) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              "Cantidad:",
                              style: AdminTheme.body(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AdminTheme.accent,
                                  inactiveTrackColor: AdminTheme.border,
                                  thumbColor: AdminTheme.accent,
                                  overlayColor: AdminTheme.accent.withValues(alpha: 0.2),
                                  valueIndicatorColor: AdminTheme.accent,
                                ),
                                child: Slider(
                                  value: _selectedLimit.toDouble(),
                                  min: 4,
                                  max: 20,
                                  divisions: 16,
                                  label: _selectedLimit.toString(),
                                  onChangeStart: (_) => setState(() {
                                    _activeStepIndex = 3;
                                    _hasInteractedWithStep3 = true;
                                  }),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedLimit = val.toInt();
                                    });
                                  },
                                ),
                              ),
                            ),
                            Text(
                              _selectedLimit.toString(),
                              style: AdminTheme.body().copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AdminTheme.surface,
                          borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                          border: Border.all(color: AdminTheme.border),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                "Mostrar botón 'Ver todos'",
                                style: AdminTheme.body(),
                              ),
                              value: _showButton,
                              activeThumbColor: AdminTheme.success,
                              activeTrackColor: AdminTheme.success.withValues(alpha: 0.2),
                              inactiveThumbColor: AdminTheme.textMuted,
                              inactiveTrackColor: AdminTheme.border,
                              onChanged: (val) {
                                setState(() {
                                  _activeStepIndex = 3;
                                  _hasInteractedWithStep3 = true;
                                  _showButton = val;
                                });
                              },
                            ),
                            if (_showButton) ...[
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _buttonTextCtrl,
                                style: AdminTheme.body(),
                                decoration: AdminTheme.inputDecoration(hintText: "Texto del botón"),
                                onTap: () => setState(() {
                                  _activeStepIndex = 3;
                                  _hasInteractedWithStep3 = true;
                                }),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                );

                final rightColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "VISTA PREVIA",
                      style: AdminTheme.caption().copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildLivePreviewWidget(_selectedLayout),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "${_getLayoutName(_selectedLayout)} · ${_selectedLayout == BlockLayout.featured ? 1 : (_selectedLayout == BlockLayout.mosaic ? 3 : _selectedLimit)} productos",
                        style: AdminTheme.caption(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AdminTheme.surface,
                        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Resumen",
                            style: AdminTheme.body().copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow("Tipo", _getLayoutName(_selectedLayout)),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            "Productos",
                            _selectedLayout == null
                                ? "Sin seleccionar"
                                : "${_selectedLayout == BlockLayout.featured ? 1 : (_selectedLayout == BlockLayout.mosaic ? 3 : _selectedLimit)} · ${_getSortName(_selectedCriteria)}",
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            "Subtítulo",
                            _subtitleCtrl.text.trim().isNotEmpty ? "Sí" : "No",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancelEditor,
                            style: AdminTheme.outlinedButton(),
                            child: Text(
                              "Cancelar",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitEditor,
                            style: AdminTheme.primaryButton(),
                            child: Text(
                              "Guardar",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );

                if (isMobile) {
                  return Column(
                    children: [
                      leftColumn,
                      const SizedBox(height: 32),
                      rightColumn,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: leftColumn),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: rightColumn),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLabel(String text, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: AdminTheme.caption().copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildLayoutCard({
    required BlockLayout layout,
    required String name,
    required String desc,
  }) {
    final isSelected = _selectedLayout == layout;
    final isHovered = _hoveredLayout == layout;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredLayout = layout),
      onExit: (_) => setState(() => _hoveredLayout = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeStepIndex = 2;
            _hasSelectedLayout = true;
            _selectedLayout = layout;
            if (layout == BlockLayout.featured) {
              _selectedCriteria = BlockSortCriteria.manual;
            }
          });
        },
        child: AnimatedScale(
          scale: isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AdminTheme.accent.withValues(alpha: 0.08)
                  : (isHovered
                      ? AdminTheme.accent.withValues(alpha: 0.02)
                      : AdminTheme.cardBg),
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              border: Border.all(
                color: isSelected
                    ? AdminTheme.accent
                    : (isHovered ? AdminTheme.accent.withValues(alpha: 0.5) : AdminTheme.border),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isHovered || isSelected)
                  BoxShadow(
                    color: AdminTheme.accent.withValues(alpha: isSelected ? 0.1 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              children: [
                _buildMiniature(layout),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: AdminTheme.body().copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                Text(
                  desc,
                  style: AdminTheme.caption().copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsIndicator() {
    final step1Done = _titleCtrl.text.trim().isNotEmpty;
    final step2Done = step1Done && _hasSelectedLayout;
    final step3Done = step2Done && (_selectedCriteria != BlockSortCriteria.manual || _selectedSpecificProductId != null) && _hasInteractedWithStep3;

    return Row(
      children: [
        _buildAnimatedStepCircle(
          index: 1,
          isDone: step1Done,
          isActive: _activeStepIndex == 1,
          stepNum: "1",
          label: "Nombre",
          targetKey: _step1Key,
        ),
        _buildStepDivider(step1Done),
        _buildAnimatedStepCircle(
          index: 2,
          isDone: step2Done,
          isActive: _activeStepIndex == 2,
          stepNum: "2",
          label: "Diseño",
          targetKey: _step2Key,
        ),
        _buildStepDivider(step2Done),
        _buildAnimatedStepCircle(
          index: 3,
          isDone: step3Done,
          isActive: _activeStepIndex == 3,
          stepNum: "3",
          label: "Contenido",
          targetKey: _step3Key,
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isDone) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDone ? AdminTheme.success : AdminTheme.border,
    );
  }

  Widget _buildAnimatedStepCircle({
    required int index,
    required bool isDone,
    required bool isActive,
    required String stepNum,
    required String label,
    required GlobalKey targetKey,
  }) {
    final theme = AdminTheme.accent;
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isDone) {
      bgColor = AdminTheme.success;
      borderColor = AdminTheme.success;
      textColor = Colors.white;
    } else if (isActive) {
      bgColor = theme.withValues(alpha: 0.1);
      borderColor = theme;
      textColor = theme;
    } else {
      bgColor = AdminTheme.surface;
      borderColor = AdminTheme.border;
      textColor = AdminTheme.textMuted;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeStepIndex = index;
          });
          final ctx = targetKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        },
        child: Tooltip(
          message: "$label - Paso $stepNum",
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: isActive ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: theme.withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) {
                      return ScaleTransition(scale: anim, child: child);
                    },
                    child: isDone
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 15,
                            key: ValueKey("check"),
                          )
                        : Text(
                            stepNum,
                            key: ValueKey("num"),
                            style: AdminTheme.caption().copyWith(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AdminTheme.caption().copyWith(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? AdminTheme.textPrimary
                      : (isDone ? AdminTheme.success : AdminTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreviewWidget(BlockLayout? layout) {
    if (layout == null) {
      return Container(
        height: 520,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.border, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android_rounded,
              size: 48,
              color: AdminTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              "Vista Previa",
              style: AdminTheme.body().copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Selecciona un diseño a la izquierda",
              style: AdminTheme.caption(),
            ),
          ],
        ),
      );
    }

    final allProducts = context.watch<ProductProvider>().products;
    final filtered = _getFilteredProducts(allProducts);

    final limit = layout == BlockLayout.featured
        ? 1
        : (layout == BlockLayout.mosaic ? 3 : _selectedLimit);

    Widget productsContent;
    if (filtered.isEmpty) {
      productsContent = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            "Sin productos para mostrar",
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ),
      );
    } else {
      productsContent = Container(
        height: 520,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.border, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 360,
              height: 640,
              child: Theme(
                data: ThemeData.light().copyWith(
                  scaffoldBackgroundColor: Colors.white,
                  cardColor: Colors.white,
                  dividerColor: Colors.grey.shade200,
                ),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: const Size(360, 640),
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    body: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: HomeBlockRenderer(
                          isPreview: true,
                          block: HomeBlock(
                            id: 'preview',
                            layout: layout,
                            title: _titleCtrl.text.isEmpty ? "Título de la Sección" : _titleCtrl.text,
                            subtitle: _subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim(),
                            showButton: _showButton,
                            buttonText: _showButton && _buttonTextCtrl.text.trim().isNotEmpty
                                ? _buttonTextCtrl.text.trim()
                                : null,
                            sortCriteria: _selectedCriteria ?? BlockSortCriteria.newest,
                            itemsLimit: limit,
                          ),
                          products: filtered,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      key: ValueKey("${layout.name}_${filtered.length}_${_titleCtrl.text}"),
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminTheme.border, width: 1.5),
      ),
      child: productsContent,
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AdminTheme.caption(),
        ),
        Text(
          value,
          style: AdminTheme.body().copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getLayoutName(BlockLayout? layout) {
    if (layout == null) return "Sin seleccionar";
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

  String _getSortName(BlockSortCriteria? criteria) {
    if (criteria == null) return "Sin seleccionar";
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
