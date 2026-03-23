import 'package:flutter/material.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text("Admin Panel"),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: const Color(0xFFE2E2E2), height: 1.0),
              ),
            ),
            drawer: Drawer(
              child: AdminLeftSide(businessSlug: businessSlug),
            ),
            body: child,
          );
        }

        return Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 2,
                child: AdminLeftSide(businessSlug: businessSlug),
              ),
              Expanded(flex: 8, child: child),
            ],
          ),
        );
      },
    );
  }
}
