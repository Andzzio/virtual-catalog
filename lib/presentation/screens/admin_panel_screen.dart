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
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 2, child: AdminLeftSide(businessSlug: businessSlug)),
          Expanded(flex: 8, child: child),
        ],
      ),
    );
  }
}
