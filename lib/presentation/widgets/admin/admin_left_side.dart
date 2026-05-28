import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virtual_catalog_app/config/routers/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminLeftSide extends StatelessWidget {
  final String businessSlug;
  const AdminLeftSide({super.key, required this.businessSlug});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final businessName =
        context.watch<BusinessProvider>().business?.name ?? 'Mi Negocio';

    return Material(
      color: AdminTheme.sidebarBg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AdminTheme.accent, AdminTheme.textSecondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.storefront_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.getFont(
                              FontNames.fontNameH2,
                              textStyle: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            children: const [
                              TextSpan(
                                text: 'Chani',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: '.pe',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AdminTheme.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          businessName,
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AdminTheme.sidebarTextMuted,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                  color: Colors.white.withValues(alpha: 0.08), height: 1),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("GENERAL"),
                    const SizedBox(height: 4),
                    _navItem(
                      context,
                      icon: Icons.dashboard_rounded,
                      label: "Dashboard",
                      route: "/$businessSlug/admin/dashboard",
                      currentPath: currentPath,
                      tooltip: "Resumen de ventas y pedidos",
                    ),
                    _navItem(
                      context,
                      icon: Icons.inventory_2_rounded,
                      label: "Productos",
                      route: "/$businessSlug/admin/products",
                      currentPath: currentPath,
                      tooltip: "Gestiona tu inventario",
                    ),
                    _navItem(
                      context,
                      icon: Icons.qr_code_scanner_rounded,
                      label: "Etiquetas / Hangtags",
                      route: "/$businessSlug/admin/stickers",
                      currentPath: currentPath,
                      tooltip: "Impresión de códigos de barra y etiquetas",
                    ),
                    _navItem(
                      context,
                      icon: Icons.receipt_long_rounded,
                      label: "Ventas",
                      route: "/$businessSlug/admin/sales",
                      currentPath: currentPath,
                      tooltip: "Historial de comprobantes emitidos",
                    ),
                    _navItem(
                      context,
                      icon: Icons.chat_bubble_outline_rounded,
                      label: "Mensajes (Inbox)",
                      route: "/$businessSlug/admin/inbox",
                      currentPath: currentPath,
                      tooltip: "Bandeja de chat e interacciones",
                    ),
                    _navItem(
                      context,
                      icon: Icons.inventory_rounded,
                      label: "Inventario",
                      route: "/$businessSlug/admin/inventory",
                      currentPath: currentPath,
                      tooltip: "Kardex de entradas y salidas",
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel("APARIENCIA"),
                    const SizedBox(height: 4),
                    _navItem(
                      context,
                      icon: Icons.image_rounded,
                      label: "Banners",
                      route: "/$businessSlug/admin/banners",
                      currentPath: currentPath,
                      tooltip: "Imágenes del carrusel principal",
                    ),
                    _navItem(
                      context,
                      icon: Icons.view_quilt_rounded,
                      label: "Diseño del Home",
                      route: "/$businessSlug/admin/home-builder",
                      currentPath: currentPath,
                      tooltip: "Personaliza tu página principal",
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel("CONFIGURACIÓN"),
                    const SizedBox(height: 4),
                    _navItem(
                      context,
                      icon: Icons.settings_rounded,
                      label: "Ajustes",
                      route: "/$businessSlug/admin/settings",
                      currentPath: currentPath,
                      tooltip: "Datos del negocio, pagos y envíos",
                    ),
                    _navItem(
                      context,
                      icon: Icons.location_on_rounded,
                      label: "Ubicaciones",
                      route: "/$businessSlug/admin/locations",
                      currentPath: currentPath,
                      tooltip: "Provincias y Distritos de entrega",
                    ),
                    _navItem(
                      context,
                      icon: Icons.people_alt_rounded,
                      label: "Usuarios",
                      route: "/$businessSlug/admin/users",
                      currentPath: currentPath,
                      tooltip: "Gestión de accesos y vendedores",
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Divider(
                  color: Colors.white.withValues(alpha: 0.08), height: 1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_outline_rounded,
                        color: AdminTheme.sidebarTextMuted, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Administrador",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AdminTheme.sidebarText,
                            ),
                          ),
                        ),
                        Text(
                          businessSlug,
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: const TextStyle(
                              fontSize: 11,
                              color: AdminTheme.sidebarTextMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: "Cerrar sesión",
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            NavigationHelper.go(context, '/$businessSlug/admin/login');
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AdminTheme.sidebarTextMuted,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AdminTheme.sidebarTextMuted.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required String currentPath,
    String? tooltip,
  }) {
    final isActive = currentPath.startsWith(route);

    return Tooltip(
      message: tooltip ?? label,
      waitDuration: const Duration(milliseconds: 600),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
          onTap: () {
            NavigationHelper.go(context, route);
            if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
              Navigator.of(context).pop();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              border: isActive
                  ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isActive ? Colors.white : AdminTheme.sidebarTextMuted,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isActive ? Colors.white : AdminTheme.sidebarText,
                    ),
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AdminTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
