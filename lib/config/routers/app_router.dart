import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/screens/screens.dart';
import 'package:virtual_catalog_app/presentation/widgets/empty_state_widget.dart';
import '../../presentation/widgets/admin/products/admin_products_view.dart';

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
        final slug = state.pathParameters["businessSlug"]!;
        final location = state.uri.path;
        final isGoingToLogin = location.endsWith("/login");
        final isGoingToAdmin =
            location == "/$slug/admin" || location == "/$slug/admin/";
        if (!isAuth) {
          if (!isGoingToLogin) {
            return "/$slug/admin/login";
          }
        } else {
          if (isGoingToLogin || isGoingToAdmin) {
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
        ShellRoute(
          builder: (context, state, child) {
            final slug = state.pathParameters["businessSlug"]!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ProductProvider>().loadProducts(slug);
            });

            return AdminPanelScreen(businessSlug: slug, child: child);
          },
          routes: [
            GoRoute(
              path: "dashboard",
              builder: (context, state) {
                return EmptyStateWidget(
                  title: "Dashboard",
                  subtitle: "Proximamente",
                );
              },
            ),
            GoRoute(
              path: "products",
              builder: (context, state) {
                final slug = state.pathParameters["businessSlug"]!;
                return AdminProductsView(businessSlug: slug);
              },
              routes: [
                GoRoute(
                  path: "create",
                  builder: (context, state) {
                    return AdminCreateProductsScreen();
                  },
                ),
              ],
            ),
            GoRoute(
              path: "banners",
              builder: (context, state) {
                return EmptyStateWidget(
                  title: "Banners",
                  subtitle: "Proximamente",
                );
              },
            ),
            GoRoute(
              path: "settings",
              builder: (context, state) {
                return EmptyStateWidget(
                  title: "Configuración",
                  subtitle: "Proximamente",
                );
              },
            ),
          ],
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
