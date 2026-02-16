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
        description:
            "Conecta con un estilo natural y chic gracias a este diseño en color rojo ladrillo con motivos de hojas blancas. Confeccionado en ligera seda polca de verano, ofrece una silueta relajada y máxima suavidad al tacto. Combínalo con tops básicos para crear un outfit veraniego inolvidable y lleno de personalidad. Además cuenta con elástico en la parte trasera de la pretina para que se amolde bien a tu cuerpo.",

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
            price: 40.0,
            stock: 40,
            sizes: ["M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "e",
        name: "Maxi Palazzo Hojas",
        description:
            "Aporta elegancia y versatilidad a tu guardarropa con este modelo en base oscura y tonos tierra. Fabricado en fresca seda polca de verano, su caída fluida y estampado de hojas grandes en contraste crean un look sofisticado que no sacrifica la comodidad. Es la prenda ideal para transicionar de un look de oficina a una cena relajada con total estilo. Además cuenta con elástico en la parte trasera de la pretina para que se amolde bien a tu cuerpo.",

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
            price: 50.0,
            stock: 40,
            sizes: ["S", "M", "L"],
          ),
          ProductVariant(
            name: "Hojas Oscuras",
            color: 0xFFC65F2F,
            price: 60.0,
            stock: 10,
            sizes: ["M", "L"],
          ),
        ],
      ),
      Product(
        id: "f",
        name: "Maxi Palazzo Naranja",
        description:
            "Ilumina tu estilo con este pantalón palazzo en un cautivador color mostaza. La tela seda polca de verano garantiza frescura y libertad de movimiento, mientras que su estampado de follaje en tonos blancos y marrones añade un aire moderno y juvenil. Una pieza clave para destacar y sentirte cómoda en cualquier evento de día. Además cuenta con elástico en la parte trasera de la pretina para que se amolde bien a tu cuerpo.",

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
            price: 60.0,
            discountPrice: 30,
            stock: 40,
            sizes: ["S", "M", "L"],
          ),
        ],
      ),
      Product(
        id: "g",
        name: "Maxi Palazzo Rosa",
        description:
            "Luce fresca y radiante con este pantalón de corte amplio y cintura alta, ideal para realzar tu figura. Confeccionado en seda polca de verano, su textura suave y ligera ofrece una caída espectacular. El diseño de fondo blanco con vibrantes estampados botánicos en tonos rosas y naranjas aporta un toque femenino y alegre, perfecto para tus salidas en días soleados. Además cuenta con elástico en la parte trasera de la pretina para que se amolde bien a tu cuerpo.",

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
            name: "Blanco",
            color: 0xFFF1F6E9,
            price: 70.0,
            stock: 40,
            sizes: ["S", "M", "XL"],
          ),
          ProductVariant(
            name: "Rosa",
            color: 0xFFD8B0BD,
            price: 70.0,
            discountPrice: 60.0,
            stock: 20,
            sizes: ["S", "M", "L"],
          ),
        ],
      ),
      Product(
        id: "h",
        name: "Maxi Palazzo Rojo",
        description:
            "Conecta con un estilo natural y chic gracias a este diseño en color rojo ladrillo con motivos de hojas blancas. Confeccionado en ligera seda polca de verano, ofrece una silueta relajada y máxima suavidad al tacto. Combínalo con tops básicos para crear un outfit veraniego inolvidable y lleno de personalidad. Además cuenta con elástico en la parte trasera de la pretina para que se amolde bien a tu cuerpo.",

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
            price: 80.0,
            stock: 40,
            sizes: ["S", "M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "i",
        name: "Maxi Palazzo Rayas",
        description:
            "Libera tu instinto de moda con este espectacular diseño animal print. El patrón de cebra aporta una vibra audaz y sofisticada, perfecta para un look con actitud fierce. Gracias a la suavidad de la seda polca de verano, disfrutarás de una caída ligera y fresca que acompaña cada uno de tus pasos con un movimiento hipnótico. Es el statement piece definitivo para elevar tus básicos y destacar con un estilo único y atemporal. Además cuenta con elástico en la parte trasera de la pretina para que se amolde bien a tu cuerpo.",

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
            price: 90.0,
            stock: 40,
            sizes: ["S", "M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "j",
        name: "Maxi Palazzo Selva",
        description:
            "Desata tu esencia libre con este impactante palazzo de animal print atigrado. Confeccionado en lino shantu, su textura natural y ligeramente rústica aporta un acabado boho-luxe irresistible y mucha frescura. El corte de pierna ancha y cintura alta estiliza tu figura mientras caminas con total fluidez. Es el equilibrio perfecto entre audacia y elegancia orgánica, diseñado para ser el protagonista absoluto de tus looks de temporada. Además cuenta con elástico en la parte trasera de la pretina para que se amolde bien a tu cuerpo.",

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
            price: 100.0,
            stock: 40,
            sizes: ["M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "a",
        name: "Black Skirt Mini",
        description:
            "Únete a la tendencia old money con esta falda-short imprescindible. Su diseño de tablas y cintura alta esculpe una silueta preppy y femenina, mientras que el short interno te regala total libertad de movimiento y seguridad. Confeccionada en resistente tela Catania, mantiene su estructura y vuelo perfecto todo el día. Disponible en un negro clásico y un terracota cálido, es la pieza clave para elevar tus básicos con una vibra juvenil y chic.",

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
            color: 0xFF000000,
            price: 10.0,
            stock: 40,
            sizes: ["S", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "b",
        name: "Black Skirt",
        description:
            "Únete a la tendencia old money con esta falda-short imprescindible. Su diseño de tablas y cintura alta esculpe una silueta preppy y femenina, mientras que el short interno te regala total libertad de movimiento y seguridad. Confeccionada en resistente tela Catania, mantiene su estructura y vuelo perfecto todo el día. Disponible en un negro clásico y un terracota cálido, es la pieza clave para elevar tus básicos con una vibra juvenil y chic.",

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
            color: 0xFF000000,
            price: 20.0,
            stock: 40,
            sizes: ["S", "M", "L", "XL"],
          ),
        ],
      ),
      Product(
        id: "c",
        name: "Black Skirt Slim",
        description:
            "Eleva tu elegancia con esta falda midi de corte lápiz, diseñada para destacar tu silueta de forma sofisticada. Confeccionada en tela Ston, su textura distintiva y ajuste perfecto realzan tus curvas con total comodidad, brindando un acabado impecable y moderno. La abertura lateral aporta ese toque de seducción sutil y movimiento necesario para romper con lo clásico. Disponible en un negro atemporal y un vino intenso, es la pieza versatile-chic que necesitas para transicionar del office look a una noche especial.",

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
            color: 0xFF000000,
            price: 30.0,
            stock: 40,
            sizes: ["S", "M", "L", "XL"],
          ),
        ],
      ),
    ];
  }
}
