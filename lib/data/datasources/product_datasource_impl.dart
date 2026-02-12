import 'package:virtual_catalog_app/domain/datasources/product_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';

class ProductDatasourceImpl implements ProductDatasource {
  @override
  Future<List<Product>> getProducts() async {
    return [
      Product(
        id: "d",
        name: "Maxi Palazzo Rojo",
        description: "Description 4",
        price: 40.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1d.jpeg",
          "assets/ShurumbaImagenes/2d.jpeg",
          "assets/ShurumbaImagenes/3d.jpeg",
          "assets/ShurumbaImagenes/4d.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category2",
        variants: [
          ProductVariant(
            name: "Palmeras Rojas",
            color: 0xFFA9342B,
            stock: 40,
            sizes: ["M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "e",
        name: "Maxi Palazzo Hojas",
        description: "Description 5",
        price: 50.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1e.jpeg",
          "assets/ShurumbaImagenes/2e.jpeg",
          "assets/ShurumbaImagenes/3e.jpeg",
          "assets/ShurumbaImagenes/4e.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category2",
        variants: [
          ProductVariant(
            name: "Hojas",
            color: 0xFFDCCCC0,
            stock: 40,
            sizes: ["S", "M", "L"],
          ),
        ],
      ),
      Product(
        id: "f",
        name: "Maxi Palazzo Naranja",
        description: "Description 6",
        price: 60.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1f.jpeg",
          "assets/ShurumbaImagenes/2f.jpeg",
          "assets/ShurumbaImagenes/3f.jpeg",
          "assets/ShurumbaImagenes/4f.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category2",
        variants: [
          ProductVariant(
            name: "Palmeras Naranjas",
            color: 0xFFFA8714,
            stock: 40,
            sizes: ["S", "M", "L"],
          ),
        ],
      ),
      Product(
        id: "g",
        name: "Maxi Palazzo Rosa",
        description: "Description 7",
        price: 70.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1g.jpeg",
          "assets/ShurumbaImagenes/2g.jpeg",
          "assets/ShurumbaImagenes/3g.jpeg",
          "assets/ShurumbaImagenes/4g.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category2",
        variants: [
          ProductVariant(
            name: "BlanquiRosa",
            color: 0xFFF1F6E9,
            stock: 40,
            sizes: ["S", "M", "XL"],
          ),
        ],
      ),
      Product(
        id: "h",
        name: "Maxi Palazzo Rojo",
        description: "Description 8",
        price: 80.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1h.jpeg",
          "assets/ShurumbaImagenes/2h.jpeg",
          "assets/ShurumbaImagenes/3h.jpeg",
          "assets/ShurumbaImagenes/4h.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category2",
        variants: [
          ProductVariant(
            name: "Palmeras Rojas",
            color: 0xFFA9342B,
            stock: 40,
            sizes: ["S", "M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "i",
        name: "Maxi Palazzo Rayas",
        description: "Description 9",
        price: 90.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1i.jpeg",
          "assets/ShurumbaImagenes/2i.jpeg",
          "assets/ShurumbaImagenes/3i.jpeg",
          "assets/ShurumbaImagenes/4i.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category2",
        variants: [
          ProductVariant(
            name: "Rayas",
            color: 0xFFDFC2B4,
            stock: 40,
            sizes: ["S", "M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "j",
        name: "Maxi Palazzo Selva",
        description: "Description 10",
        price: 100.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1j.jpeg",
          "assets/ShurumbaImagenes/2j.jpeg",
          "assets/ShurumbaImagenes/3j.jpeg",
          "assets/ShurumbaImagenes/4j.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category2",
        variants: [
          ProductVariant(
            name: "Selva",
            color: 0xFFBA8D70,
            stock: 40,
            sizes: ["M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "a",
        name: "Black Skirt Mini",
        description: "Description 1",
        price: 10.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1a.jpeg",
          "assets/ShurumbaImagenes/2a.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category1",
        variants: [
          ProductVariant(
            name: "Negro",
            color: 0x000000,
            stock: 40,
            sizes: ["S", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "b",
        name: "Black Skirt",
        description: "Description 2",
        price: 20.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1b.jpeg",
          "assets/ShurumbaImagenes/2b.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category1",
        variants: [
          ProductVariant(
            name: "Negro",
            color: 0x000000,
            stock: 40,
            sizes: ["S", "M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "c",
        name: "Black Skirt Slim",
        description: "Description 3",
        price: 30.0,
        imageUrl: [
          "assets/ShurumbaImagenes/1c.jpeg",
          "assets/ShurumbaImagenes/2c.jpeg",
          "assets/ShurumbaImagenes/3c.jpeg",
          "assets/ShurumbaImagenes/4c.jpeg",
          "assets/ShurumbaImagenes/5c.jpeg",
        ],
        businessId: "shurumba",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: "category1",
        variants: [
          ProductVariant(
            name: "Negro",
            color: 0x000000,
            stock: 40,
            sizes: ["S", "M", "L", "XL"],
          ),
        ],
      ),
    ];
  }
}
