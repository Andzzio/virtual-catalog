import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/admin_left_side.dart';

class AdminPanelScreen extends StatelessWidget {
  final String businessSlug;
  final Widget child;
  const AdminPanelScreen({
    super.key,
    required this.businessSlug,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessProvider>().business;

    // Wrap entire admin in dark theme to override app's pink/rose theme
    return Theme(
      data: AdminTheme.darkTheme,
      child: Builder(
        builder: (context) {
          if (business != null && !business.isActive) {
            return Scaffold(
              backgroundColor: AdminTheme.surface,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_person_rounded,
                        size: 80,
                        color: AdminTheme.danger,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Servicio Suspendido",
                        style: AdminTheme.heading1(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Tu cuenta de Kipux.pe se encuentra temporalmente suspendida.\n"
                        "Por favor comunícate con soporte para regularizar tu servicio.",
                        textAlign: TextAlign.center,
                        style: AdminTheme.body(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Skill: Use LayoutBuilder for parent-based decisions, not MediaQuery
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 800;

              if (isMobile) {
                return Scaffold(
                  backgroundColor: AdminTheme.surface,
                  appBar: AppBar(
                    backgroundColor: AdminTheme.sidebarBg,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    title: Text(
                      "Panel de Admin",
                      style: AdminTheme.appBarTitle(),
                    ),
                    iconTheme: const IconThemeData(color: Colors.white),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1.0),
                      child: Container(color: Colors.white.withValues(alpha: 0.08), height: 1.0),
                    ),
                  ),
                  drawer: SizedBox(
                    width: AdminTheme.sidebarWidth,
                    child: AdminLeftSide(businessSlug: businessSlug),
                  ),
                  body: child,
                );
              }

              // Desktop: fixed-width sidebar (skill: SizedBox, not Expanded flex)
              return Scaffold(
                backgroundColor: AdminTheme.surface,
                body: Row(
                  children: [
                    SizedBox(
                      width: AdminTheme.sidebarWidth,
                      child: AdminLeftSide(businessSlug: businessSlug),
                    ),
                    Expanded(child: child),
                  ],
                ),
              );
            },
          );
        }
      ),
    );
  }
}
