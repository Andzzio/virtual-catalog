import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/tenant_provider.dart';

class NavigationHelper {
  static String getSlug(BuildContext context) {
    final tenant = context.read<TenantProvider>();
    if (tenant.isCustomDomain) {
      return tenant.resolvedSlug!;
    }
    return GoRouterState.of(context).pathParameters["businessSlug"] ?? '';
  }

  static void go(BuildContext context, String fullPath) {
    final tenant = context.read<TenantProvider>();
    if (tenant.isCustomDomain) {
      final slug = tenant.resolvedSlug!;
      if (fullPath == '/$slug' || fullPath == '/$slug/') {
        context.go('/');
      } else if (fullPath.startsWith('/$slug/')) {
        context.go(fullPath.substring(slug.length + 1)); // removes "/slug"
      } else {
        context.go(fullPath);
      }
    } else {
      context.go(fullPath);
    }
  }

  static void push(BuildContext context, String fullPath) {
    final tenant = context.read<TenantProvider>();
    if (tenant.isCustomDomain) {
      final slug = tenant.resolvedSlug!;
      if (fullPath == '/$slug' || fullPath == '/$slug/') {
        context.push('/');
      } else if (fullPath.startsWith('/$slug/')) {
        context.push(fullPath.substring(slug.length + 1));
      } else {
        context.push(fullPath);
      }
    } else {
      context.push(fullPath);
    }
  }
}
