import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';

class AdminPanelScreen extends StatelessWidget {
  final String businessSlug;
  const AdminPanelScreen({super.key, required this.businessSlug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard Placeholder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/$businessSlug/admin/login');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido al Panel de Control!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
