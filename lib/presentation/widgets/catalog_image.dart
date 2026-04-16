import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CatalogImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double? optimizedWidth;
  const CatalogImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.optimizedWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _placeholder();
    }
    if (imageUrl.startsWith("http")) {
      return CachedNetworkImage(
        imageUrl: _optimizeImageUrl(imageUrl),
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => _placeholder(),
      );
    }
    return Image.asset(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  String _optimizeImageUrl(String url) {
    if (optimizedWidth == null) {
      return url.replaceFirst("/upload", "/upload/f_auto,q_auto");
    }
    return url.replaceFirst(
      "/upload",
      "/upload/f_auto,q_auto,w_${optimizedWidth!.round()}",
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
