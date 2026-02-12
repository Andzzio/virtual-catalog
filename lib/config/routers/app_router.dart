import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return SelectionArea(child: child);
      },
      routes: [
        GoRoute(path: "/", builder: (context, state) => HomeScreen()),
        GoRoute(
          path: "/product",
          builder: (context, state) {
            final product = state.extra as Product;
            return ProductDetailScreen(product: product);
          },
        ),
      ],
    ),
  ],
);
