import 'package:flutter/material.dart';
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
    // Wrap entire admin in dark theme to override app's pink/rose theme
    return Theme(
      data: AdminTheme.darkTheme,
      // Skill: Use LayoutBuilder for parent-based decisions, not MediaQuery
      child: LayoutBuilder(
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
      ),
    );
  }
}
