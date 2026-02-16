import 'package:virtual_catalog_app/domain/datasources/business_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';

class BusinessDatasourceImpl implements BusinessDatasource {
  final List<Business> _businesses = [
    Business(
      slug: "shurumba",
      name: "Shurumba Store",
      description:
          "La colección 2026. Descubre la textura del lujo moderno definida por la silueta y la gracia.",
      logoUrl: "assets/images/banner_catalogo_large.png",
      whatsappNumber: "+51908574674",
      bannerImages: [
        "assets/images/banner_catalogo_large.png",
        "assets/images/banner_catalog.png",
      ],
    ),
    Business(
      slug: "niva",
      name: "Niva Sábanas",
      description:
          "Sábanas y ropa de cama de calidad. Comodidad y estilo para tu descanso.",
      logoUrl: "assets/sabanaImages/a.jpeg",
      whatsappNumber: "+51908574674",
      bannerImages: [
        "assets/sabanaImages/a.jpeg",
        "assets/sabanaImages/c.jpeg",
        "assets/sabanaImages/b.jpeg",
        "assets/sabanaImages/e.jpeg",
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
