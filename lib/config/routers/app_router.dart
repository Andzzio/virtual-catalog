import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: "/shurumba",
  errorBuilder: (context, state) {
    return Scaffold(body: Center(child: Text("404 - Página no encontrada")));
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final slug = state.pathParameters["businessSlug"];
        if (slug != null) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            context.read<ProductProvider>().loadProducts(slug);
            context.read<BusinessProvider>().loadBusiness(slug);
          });
        }
        return SelectionArea(child: child);
      },
      routes: [
        GoRoute(
          path: "/:businessSlug",
          builder: (context, state) {
            final slug = state.pathParameters["businessSlug"];
            return HomeScreen(businessSlug: slug);
          },
          routes: [
            GoRoute(
              path: "product/:productId",
              builder: (context, state) {
                final slug = state.pathParameters["businessSlug"];
                final productId = state.pathParameters["productId"];
                return ProductDetailScreen(
                  businessSlug: slug,
                  productId: productId,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
