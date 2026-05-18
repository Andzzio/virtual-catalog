import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/screens/screens.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/banners/admin_banners_view.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/dashboard/admin_dashboard_view.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/home_builder/admin_home_builder_view.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/settings/admin_settings_view.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/locations/admin_shipping_zones_view.dart';
import '../../presentation/widgets/admin/products/admin_products_view.dart';
import 'package:virtual_catalog_app/presentation/providers/tenant_provider.dart';

class AppRouter {
  static String _getSlug(BuildContext context, GoRouterState state) {
    final tenant = context.read<TenantProvider>();
    if (tenant.isCustomDomain) {
      return tenant.resolvedSlug!;
    }
    return state.pathParameters["businessSlug"]!;
  }

  static GoRouter? _instance;

  static GoRouter create(TenantProvider tenant) {
    if (_instance != null) return _instance!;

    final isCustom = tenant.isCustomDomain;
    final String adminPath = isCustom ? "/admin" : "/:businessSlug/admin";
    final String basePath = isCustom ? "/" : "/:businessSlug";

    _instance = GoRouter(
      initialLocation: isCustom ? "/" : "/shurumba",
      errorBuilder: (context, state) {
        return const Scaffold(body: Center(child: Text("404 - Página no encontrada")));
      },
      routes: [
        GoRoute(
          path: adminPath,
      redirect: (context, state) {
        final isAuth = context.read<AuthProvider>().isAuthenticated;
        final slug = _getSlug(context, state);
        final location = state.uri.path;
        final isGoingToLogin = location.endsWith("/login");
        
        final evaluatedAdminPath = isCustom ? "/admin" : "/$slug/admin";
        final isGoingToAdmin = location == evaluatedAdminPath || location == "$evaluatedAdminPath/";
        
        final targetLogin = isCustom ? "/admin/login" : "/$slug/admin/login";
        final targetDashboard = isCustom ? "/admin/dashboard" : "/$slug/admin/dashboard";

        if (!isAuth) {
          if (!isGoingToLogin) {
            return targetLogin;
          }
        } else {
          if (isGoingToLogin || isGoingToAdmin) {
            return targetDashboard;
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
            final slug = _getSlug(context, state);
            return AdminLoginScreen(businessSlug: slug);
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            final slug = _getSlug(context, state);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ProductProvider>().loadProducts(slug);
              context.read<BusinessProvider>().loadBusiness(slug);
            });

            return AdminPanelScreen(businessSlug: slug, child: child);
          },
          routes: [
            GoRoute(
              path: "dashboard",
              builder: (context, state) {
                final slug = _getSlug(context, state);
                return AdminDashboardView(businessSlug: slug);
              },
            ),
            GoRoute(
              path: "products",
              builder: (context, state) {
                final slug = _getSlug(context, state);
                return AdminProductsView(businessSlug: slug);
              },
              routes: [
                GoRoute(
                  path: "create",
                  builder: (context, state) {
                    return AdminCreateProductsScreen();
                  },
                ),
                GoRoute(
                  path: "edit/:productId",
                  builder: (context, state) {
                    final productId = state.pathParameters["productId"]!;
                    final products =
                        context.read<ProductProvider>().products;
                    final product = products.firstWhere(
                      (p) => p.id == productId,
                      orElse: () => products.first,
                    );
                    return AdminCreateProductsScreen(product: product);
                  },
                ),
              ],
            ),
            GoRoute(
              path: "banners",
              builder: (context, state) {
                final slug = _getSlug(context, state);
                return AdminBannersView(businessSlug: slug);
              },
            ),
            GoRoute(
              path: "settings",
              builder: (context, state) {
                final slug = _getSlug(context, state);
                return AdminSettingsView(businessSlug: slug);
              },
            ),
            GoRoute(
              path: "home-builder",
              builder: (context, state) {
                final slug = _getSlug(context, state);
                return AdminHomeBuilderView(businessSlug: slug);
              },
            ),
            GoRoute(
              path: "locations",
              builder: (context, state) {
                final slug = _getSlug(context, state);
                return AdminShippingZonesView(businessSlug: slug);
              },
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) {
        final slug = _getSlug(context, state);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          context.read<ProductProvider>().loadProducts(slug);
          context.read<BusinessProvider>().loadBusiness(slug);
          context.read<CartProvider>().setBusinessSlug(slug);
        });
        return SelectionArea(child: child);
      },
      routes: [
        GoRoute(
          path: basePath,
          builder: (context, state) {
            final slug = _getSlug(context, state);
            return HomeScreen(businessSlug: slug);
          },
          routes: [
            GoRoute(
              path: "product/:productId",
              builder: (context, state) {
                final slug = _getSlug(context, state);
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
                  final slug = _getSlug(context, state);
                  return isCustom ? "/" : "/$slug";
                }
                return null;
              },
              builder: (context, state) {
                return CheckoutScreen();
              },
            ),
            GoRoute(
              path: "terms",
              redirect: (context, state) {
                final business = context.read<BusinessProvider>().business;
                if (business == null ||
                    business.termsAndConditions == null ||
                    business.termsAndConditions!.trim().isEmpty) {
                  final slug = _getSlug(context, state);
                  return isCustom ? "/" : "/$slug";
                }
                return null;
              },
              builder: (context, state) {
                return const TermsScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
  );
  return _instance!;
  }
}
