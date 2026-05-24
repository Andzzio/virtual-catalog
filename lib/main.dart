import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:virtual_catalog_app/config/routers/app_router.dart';
import 'package:virtual_catalog_app/config/themes/theme_config.dart';
import 'package:virtual_catalog_app/data/datasources/auth_datasource_impl.dart';
import 'package:virtual_catalog_app/data/datasources/business_datasource_impl.dart';
import 'package:virtual_catalog_app/data/datasources/cart_datasource_impl.dart';
import 'package:virtual_catalog_app/data/datasources/izipay_datasource_impl.dart';
import 'package:virtual_catalog_app/data/datasources/product_datasource_impl.dart';
import 'package:virtual_catalog_app/data/datasources/stock_movement_datasource_impl.dart';
import 'package:virtual_catalog_app/data/datasources/ubigeo_datasource_impl.dart';
import 'package:virtual_catalog_app/data/datasources/shipping_zone_datasource_impl.dart';
import 'package:virtual_catalog_app/data/repos/auth_repository_impl.dart';
import 'package:virtual_catalog_app/data/repos/stock_movement_repository_impl.dart';
import 'package:virtual_catalog_app/data/repos/business_repository_impl.dart';
import 'package:virtual_catalog_app/data/repos/cart_repository_impl.dart';
import 'package:virtual_catalog_app/data/repos/izipay_repository_impl.dart';
import 'package:virtual_catalog_app/data/repos/order_repository_impl.dart';
import 'package:virtual_catalog_app/data/repos/product_repository_impl.dart';
import 'package:virtual_catalog_app/data/repos/ubigeo_repository_impl.dart';
import 'package:virtual_catalog_app/data/repos/shipping_zone_repository_impl.dart';
import 'package:virtual_catalog_app/domain/usecases/create_izipay_payment.dart';
import 'package:virtual_catalog_app/domain/usecases/get_business_by_domain.dart';
import 'package:virtual_catalog_app/domain/usecases/get_departamentos.dart';
import 'package:virtual_catalog_app/domain/usecases/get_provincias.dart';
import 'package:virtual_catalog_app/domain/usecases/get_distritos.dart';
import 'package:virtual_catalog_app/domain/usecases/get_shipping_zones.dart';
import 'package:virtual_catalog_app/domain/usecases/save_shipping_zones.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/izipay_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/order_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/tenant_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/ubigeo_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/shipping_zone_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/stock_movement_provider.dart';
import 'package:virtual_catalog_app/data/datasources/sale_datasource_impl.dart';
import 'package:virtual_catalog_app/data/repos/sale_repository_impl.dart';
import 'package:virtual_catalog_app/domain/usecases/create_sale.dart';
import 'package:virtual_catalog_app/domain/usecases/get_sales.dart';
import 'package:virtual_catalog_app/presentation/providers/sales_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();

    final ubigeoDatasource = UbigeoDatasourceImpl(dio: dio);
    final ubigeoRepo = UbigeoRepositoryImpl(datasource: ubigeoDatasource);

    final shippingZoneDatasource = ShippingZoneDatasourceImpl();
    final shippingZoneRepo = ShippingZoneRepositoryImpl(datasource: shippingZoneDatasource);
    final stockMovementRepo = StockMovementRepositoryImpl(datasource: StockMovementDatasourceImpl());
    final saleRepo = SaleRepositoryImpl(datasource: SaleDatasourceImpl());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TenantProvider(
            getBusinessByDomain: GetBusinessByDomain(
              BusinessRepositoryImpl(datasource: BusinessDatasourceImpl()),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            repository: ProductRepositoryImpl(
              datasource: ProductDatasourceImpl(),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(
            repository: CartRepositoryImpl(datasource: CartDatasourceImpl()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BusinessProvider(
            repository: BusinessRepositoryImpl(
              datasource: BusinessDatasourceImpl(),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: AuthRepositoryImpl(
              datasource: AuthDatasourceImpl(),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => IzipayProvider(
            createIzipayPaymentUseCase: CreateIzipayPaymentUseCase(
              IzipayRepositoryImpl(
                izipayDataSource: IzipayDatasourceImpl(dio: dio),
              ),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(repository: OrderRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => UbigeoProvider(
            getDepartamentos: GetDepartamentos(ubigeoRepo),
            getProvincias: GetProvincias(ubigeoRepo),
            getDistritos: GetDistritos(ubigeoRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ShippingZoneProvider(
            getShippingZones: GetShippingZones(shippingZoneRepo),
            saveShippingZones: SaveShippingZones(shippingZoneRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StockMovementProvider(
            repository: stockMovementRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SalesProvider(
            getSalesUseCase: GetSales(saleRepo),
            createSaleUseCase: CreateSale(saleRepo),
            stockMovementRepository: stockMovementRepo,
          ),
        ),
      ],
      child: Consumer2<TenantProvider, BusinessProvider>(
        builder: (context, tenantProvider, businessProvider, child) {
          if (tenantProvider.isLoading) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (tenantProvider.errorMessage != null) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Text(
                    tenantProvider.errorMessage!,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
          }

          final business = businessProvider.business;
          final customColor = ThemeConfig.hexToColor(business?.themeColorHex);
          final customBgColor = ThemeConfig.hexToColor(
            business?.backgroundColorHex,
          );

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: business?.name ?? "Virtual Catalog",
            theme: ThemeConfig(
              selectedColor: 0,
              customColor: customColor,
              customBgColor: customBgColor,
            ).getTheme(),
            routerConfig: AppRouter.create(tenantProvider),
          );
        },
      ),
    );
  }
}
