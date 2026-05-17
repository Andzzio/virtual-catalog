import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/banner_item.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminBannerCard extends StatelessWidget {
  final BannerItem banner;
  final int index;
  final int totalCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(int delta) onMove;

  const AdminBannerCard({
    super.key,
    required this.banner,
    required this.index,
    required this.totalCount,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AdminTheme.cardDecoration(),
      // Skill: clip to prevent image bleeding outside border radius
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image — fills available space
          Expanded(
            child: Image.network(
              banner.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AdminTheme.cardBg,
                child: Center(
                  child: Icon(Icons.broken_image, size: 40, color: AdminTheme.textMuted),
                ),
              ),
            ),
          ),
          // Info & Actions — fixed height, no overflow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AdminTheme.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "#${index + 1}",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    banner.title,
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Reordering Arrows
                if (totalCount > 1) ...[
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 16),
                      onPressed: index == 0 ? null : () => onMove(-1),
                      tooltip: "Subir",
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 16),
                      onPressed: index == totalCount - 1 ? null : () => onMove(1),
                      tooltip: "Bajar",
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                // Skill: 40×40 hit areas
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEdit,
                    tooltip: "Editar",
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: AdminTheme.danger),
                    onPressed: onDelete,
                    tooltip: "Eliminar",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
