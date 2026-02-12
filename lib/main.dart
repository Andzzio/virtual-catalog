import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:virtual_catalog_app/config/themes/theme_config.dart';
import 'package:virtual_catalog_app/data/datasources/product_datasource_impl.dart';
import 'package:virtual_catalog_app/data/repos/product_repository_impl.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/screens/home_screen.dart';

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
          )..loadProducts(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig(selectedColor: 0).getTheme(),
        home: HomeScreen(),
      ),
    );
  }
}
