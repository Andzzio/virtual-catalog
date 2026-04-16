import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/banner_item.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
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
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (business == null) {
      return const Center(child: Text("No se pudo cargar el negocio."));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Banners",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "Gestiona los banners de tu tienda.",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle:
                          TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showBannerDialog(context, business),
                icon: const Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: Text(
                  "Agregar Banner",
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Content
          Expanded(
            child: business.banners.isEmpty
                ? _buildEmptyState()
                : _buildBannerGrid(context, business),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Sin banners aún",
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Los banners aparecerán en el carrusel de la página principal.",
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerGrid(BuildContext context, Business business) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.05,
      ),
      itemCount: business.banners.length,
      itemBuilder: (context, index) {
        return AdminBannerCard(
          banner: business.banners[index],
          index: index,
          onEdit: () =>
              _showBannerDialog(context, business, editIndex: index),
          onDelete: () =>
              _confirmDelete(context, business, index),
        );
      },
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              backgroundColor: Colors.redAccent,
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
