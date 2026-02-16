import 'package:virtual_catalog_app/domain/datasources/business_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/banner_item.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';

class BusinessDatasourceImpl implements BusinessDatasource {
  final List<Business> _businesses = [
    Business(
      slug: "shurumba",
      name: "SHURUMBA",
      description:
          "La colección 2026. Descubre la textura del lujo moderno definida por la silueta y la gracia.",
      logoUrl: "assets/images/banner_catalogo_large.png",
      whatsappNumber: "+51908574674",
      banners: [
        BannerItem(
          imageUrl: "assets/images/banner_catalogo_large.png",
          title: "Colección 2026",
          subtitle:
              "Descubre la textura del lujo moderno definida por la silueta y la gracia.",
        ),
        BannerItem(
          imageUrl: "assets/images/banner_catalog.png",
          title: "Nuevos Llegados",
          subtitle: "Las últimas tendencias en moda femenina ya están aquí.",
        ),
      ],
    ),
    Business(
      slug: "niva",
      name: "NIVA",
      description:
          "Sábanas y ropa de cama de calidad. Comodidad y estilo para tu descanso.",
      logoUrl: "assets/sabanaImages/a.jpeg",
      whatsappNumber: "+51908574674",
      banners: [
        BannerItem(
          imageUrl: "assets/sabanaImages/a.jpeg",
          title: "Sábanas Florales",
          subtitle:
              "Alegría y color para tu habitación con nuestros diseños exclusivos.",
        ),
        BannerItem(
          imageUrl: "assets/sabanaImages/c.jpeg",
          title: "Colección Love",
          subtitle: "Sábanas con diseños románticos para noches especiales.",
        ),
        BannerItem(
          imageUrl: "assets/sabanaImages/b.jpeg",
          title: "Línea Tierra",
          subtitle: "Tonos cálidos y elegantes para un estilo sofisticado.",
        ),
        BannerItem(
          imageUrl: "assets/sabanaImages/e.jpeg",
          title: "Estilo Retro",
          subtitle: "Diseños geométricos con personalidad y carácter.",
        ),
      ],
    ),
  ];

  @override
  Future<Business?> getBusinessBySlug(String slug) async {
    try {
      return _businesses.firstWhere((business) => business.slug == slug);
    } catch (e) {
      return null;
    }
  }
}
