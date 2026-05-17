import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/banner_item.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/banners/admin_banner_card.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/banners/admin_banner_dialog.dart';

class AdminBannersView extends StatelessWidget {
  final String businessSlug;
  const AdminBannersView({super.key, required this.businessSlug});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    final business = provider.business;

    if (provider.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AdminTheme.accent));
    }

    if (business == null) {
      return const Center(child: Text("No se pudo cargar el negocio."));
    }

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
              "Banners",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "Imágenes del carrusel principal de tu tienda.",
              style: AdminTheme.bodySmall(),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showBannerDialog(context, business),
            icon: const Icon(Icons.add),
            style: AdminTheme.primaryButton(),
            label: Text(
              "Agregar Banner",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: business.banners.isEmpty
            ? _buildEmptyState()
            : _buildBannerGrid(context, business),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 64, color: AdminTheme.textMuted),
          const SizedBox(height: 16),
          Text("Sin banners aún",
              style: AdminTheme.heading2()
                  .copyWith(color: AdminTheme.textSecondary)),
          const SizedBox(height: 8),
          Text(
            "Los banners aparecerán en el carrusel de la página principal.",
            style: AdminTheme.bodySmall(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerGrid(BuildContext context, Business business) {
    final banners = business.banners;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: 220,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return AdminBannerCard(
                banner: banners[index],
                index: index,
                totalCount: banners.length,
                onEdit: () =>
                    _showBannerDialog(context, business, editIndex: index),
                onDelete: () => _confirmDelete(context, business, index),
                onMove: (delta) => _moveBanner(context, business, index, delta),
              );
            },
          );
        }
        return ListView.builder(
          itemCount: banners.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                height: 180,
                child: AdminBannerCard(
                  banner: banners[index],
                  index: index,
                  totalCount: banners.length,
                  onEdit: () =>
                      _showBannerDialog(context, business, editIndex: index),
                  onDelete: () => _confirmDelete(context, business, index),
                  onMove: (delta) => _moveBanner(context, business, index, delta),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _moveBanner(
    BuildContext context,
    Business business,
    int index,
    int delta,
  ) async {
    final targetIndex = index + delta;
    if (targetIndex < 0 || targetIndex >= business.banners.length) return;

    final updatedBanners = List<BannerItem>.from(business.banners);
    final item = updatedBanners.removeAt(index);
    updatedBanners.insert(targetIndex, item);

    final updated = Business(
      slug: business.slug,
      ownerId: business.ownerId,
      name: business.name,
      description: business.description,
      logoUrl: business.logoUrl,
      whatsappNumber: business.whatsappNumber,
      banners: updatedBanners,
      deliveryMethods: business.deliveryMethods,
      paymentMethods: business.paymentMethods,
      showDesktopLogo: business.showDesktopLogo,
      showMobileLogo: business.showMobileLogo,
      termsAndConditions: business.termsAndConditions,
      homeBlocks: business.homeBlocks,
    );

    try {
      await context.read<BusinessProvider>().updateBusiness(updated);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error al mover: $e")),
        );
      }
    }
  }

  Future<void> _showBannerDialog(
    BuildContext context,
    Business business, {
    int? editIndex,
  }) async {
    final isEditing = editIndex != null;
    final existing = isEditing ? business.banners[editIndex] : null;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AdminBannerDialog(
        initialTitle: existing?.title,
        initialSubtitle: existing?.subtitle,
        initialImageUrl: existing?.imageUrl,
        initialMobileImageUrl: existing?.mobileImageUrl,
      ),
    );

    if (result == null || !context.mounted) return;

    final newBanner = BannerItem(
      imageUrl: result["imageUrl"]!,
      mobileImageUrl: result["mobileImageUrl"],
      title: result["title"]!,
      subtitle: result["subtitle"]!,
    );

    final updatedBanners = List<BannerItem>.from(business.banners);
    if (isEditing) {
      updatedBanners[editIndex] = newBanner;
    } else {
      updatedBanners.add(newBanner);
    }

    final updated = Business(
      slug: business.slug,
      ownerId: business.ownerId,
      name: business.name,
      description: business.description,
      logoUrl: business.logoUrl,
      whatsappNumber: business.whatsappNumber,
      banners: updatedBanners,
      deliveryMethods: business.deliveryMethods,
      paymentMethods: business.paymentMethods,
      showDesktopLogo: business.showDesktopLogo,
      showMobileLogo: business.showMobileLogo,
      termsAndConditions: business.termsAndConditions,
      homeBlocks: business.homeBlocks,
    );

    try {
      await context.read<BusinessProvider>().updateBusiness(updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? "✅ Banner actualizado"
                : "✅ Banner creado con éxito",
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Business business,
    int index,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminTheme.radiusLg)),
        title: Text(
          "Eliminar Banner",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Text(
          "¿Estás seguro de que deseas eliminar \"${business.banners[index].title}\"?",
          style: GoogleFonts.getFont(FontNames.fontNameH2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              "Cancelar",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Eliminar",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final updatedBanners = List<BannerItem>.from(business.banners)
      ..removeAt(index);

    final updated = Business(
      slug: business.slug,
      ownerId: business.ownerId,
      name: business.name,
      description: business.description,
      logoUrl: business.logoUrl,
      whatsappNumber: business.whatsappNumber,
      banners: updatedBanners,
      deliveryMethods: business.deliveryMethods,
      paymentMethods: business.paymentMethods,
      showDesktopLogo: business.showDesktopLogo,
      showMobileLogo: business.showMobileLogo,
      termsAndConditions: business.termsAndConditions,
      homeBlocks: business.homeBlocks,
    );

    try {
      await context.read<BusinessProvider>().updateBusiness(updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Banner eliminado")),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }
}
