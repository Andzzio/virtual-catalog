import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: "/shurumba",
  errorBuilder: (context, state) {
    return Scaffold(body: Center(child: Text("404 - Página no encontrada")));
  },
  routes: [
    GoRoute(
      path: "/:businessSlug/admin",
      redirect: (context, state) {
        final isAuth = context.read<AuthProvider>().isAuthenticated;

        final isGoingToLogin = state.matchedLocation.endsWith("/login");
        final isGoingToAdmin = state.matchedLocation.endsWith("/admin");
        if (!isAuth) {
          if (!isGoingToLogin) {
            final slug = state.pathParameters["businessSlug"];
            return "/$slug/admin/login";
          }
        } else {
          if (isGoingToLogin || isGoingToAdmin) {
            final slug = state.pathParameters["businessSlug"];
            return "/$slug/admin/dashboard";
          }
        }
        return null;
      },
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text("Cargando Admin..."))),
      routes: [
        GoRoute(
          path: "login",
          builder: (context, state) {
            final slug = state.pathParameters["businessSlug"]!;
            return AdminLoginScreen(businessSlug: slug);
          },
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) {
        final slug = state.pathParameters["businessSlug"];
        if (slug != null) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            context.read<ProductProvider>().loadProducts(slug);
            context.read<BusinessProvider>().loadBusiness(slug);
            context.read<CartProvider>().setBusinessSlug(slug);
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
            GoRoute(
              path: "catalog",
              builder: (context, state) {
                final params = state.uri.queryParameters;
                return CatalogScreen(
                  initialSearch: params["search"],
                  initialCategory: params["category"],
                  initialSort: params["sort"],
                  initialMinPrice: double.tryParse(params["minPrice"] ?? ""),
                  initialMaxPrice: double.tryParse(params["maxPrice"] ?? ""),
                  initialSizes: params["sizes"]?.split(",").toSet(),
                  initialAvailable: params["available"] == "true" ? true : null,
                );
              },
            ),
            GoRoute(
              path: "checkout",
              redirect: (context, state) {
                final CartProvider cartProvider = context.read<CartProvider>();
                if (cartProvider.checkItems.isEmpty) {
                  final slug = state.pathParameters["businessSlug"];
                  return "/$slug";
                }
                return null;
              },
              builder: (context, state) {
                return CheckoutScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
