import 'package:virtual_catalog_app/domain/entities/product.dart';

class FilterCatalog {
  static List<Product> filterProducts(
    List<Product> products, {
    String? search,
    String? category,
    String? sort,
    double? minPrice,
    double? maxPrice,
    Set<String>? sizes,
    bool? available,
  }) {
    final filtered = products.where((product) {
      final productPrice = product.variants.isEmpty
          ? 0.0
          : product.variants
              .map((v) => v.discountPrice ?? v.price)
              .reduce((a, b) => a < b ? a : b);
      final matchSearch =
          search == null ||
          search.isEmpty ||
          product.name.toLowerCase().contains(search.toLowerCase());
      final matchCategory =
          category == null ||
          category == "Todos" ||
          product.category == category;
      final matchMinPrice =
          minPrice == null || minPrice == 0 || productPrice >= minPrice;
      final matchMaxPrice =
          maxPrice == null || maxPrice == 0 || productPrice <= maxPrice;
      final matchSize =
          sizes == null ||
          sizes.isEmpty ||
          product.variants.any((v) => v.sizes.any((s) => sizes.contains(s)));
      final matchAvailable = available != true || product.isAvailable;
      return matchSearch &&
          matchCategory &&
          matchMinPrice &&
          matchMaxPrice &&
          matchSize &&
          matchAvailable;
    }).toList();
    if (sort == "Mayor Precio") {
      filtered.sort((a, b) {
        final aPrice = a.variants.isEmpty
            ? 0.0
            : a.variants
                .map((v) => v.discountPrice ?? v.price)
                .reduce((x, y) => x < y ? x : y);
        final bPrice = b.variants.isEmpty
            ? 0.0
            : b.variants
                .map((v) => v.discountPrice ?? v.price)
                .reduce((x, y) => x < y ? x : y);
        return bPrice.compareTo(aPrice);
      });
    } else if (sort == "Menor Precio") {
      filtered.sort((a, b) {
        final aPrice = a.variants.isEmpty
            ? 0.0
            : a.variants
                .map((v) => v.discountPrice ?? v.price)
                .reduce((x, y) => x < y ? x : y);
        final bPrice = b.variants.isEmpty
            ? 0.0
            : b.variants
                .map((v) => v.discountPrice ?? v.price)
                .reduce((x, y) => x < y ? x : y);
        return aPrice.compareTo(bPrice);
      });
    }
    return filtered;
  }

  static String buildCatalogUrl(
    String? slug, {
    String? search,
    String? category,
    String? sort,
    double? minPrice,
    double? maxPrice,
    Set<String>? sizes,
    bool? available,
  }) {
    final Map<String, String> params = {};
    if (search != null && search.isNotEmpty) params["search"] = search;
    if (category != null && category != "Todos") params["category"] = category;
    if (sort != null && sort != "Relevantes") params["sort"] = sort;
    if (minPrice != null && minPrice > 0) {
      params["minPrice"] = minPrice.toString();
    }
    if (maxPrice != null && maxPrice > 0) {
      params["maxPrice"] = maxPrice.toString();
    }
    if (sizes != null && sizes.isNotEmpty) params["sizes"] = sizes.join(",");
    if (available == true) params["available"] = "true";
    final queryString = params.entries
        .map((e) => "${e.key}=${e.value}")
        .join("&");
    return "/$slug/catalog${queryString.isNotEmpty ? '?$queryString' : ''}";
  }

  static List<String> extractCategories(List<Product> products) {
    final cats = products.map((p) => p.category).toSet().toList();
    cats.sort();
    cats.insert(0, "Todos");
    return cats;
  }

  static List<String> extractSizes(List<Product> products) {
    final allSizes = products
        .expand((p) => p.variants)
        .expand((v) => v.sizes)
        .toSet()
        .toList();
    allSizes.sort();
    return allSizes;
  }
}
