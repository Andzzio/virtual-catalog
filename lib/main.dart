import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:virtual_catalog_app/config/routers/app_router.dart';
import 'package:virtual_catalog_app/config/themes/theme_config.dart';
import 'package:virtual_catalog_app/data/datasources/product_datasource_impl.dart';
import 'package:virtual_catalog_app/data/repos/product_repository_impl.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            repository: ProductRepositoryImpl(
              datasource: ProductDatasourceImpl(),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig(selectedColor: 0).getTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}
