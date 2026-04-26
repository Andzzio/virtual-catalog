import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_image.dart';

class ProductImageSection extends StatefulWidget {
  final Product product;
  const ProductImageSection({super.key, required this.product});

  @override
  State<ProductImageSection> createState() => _ProductImageSectionState();
}

class _ProductImageSectionState extends State<ProductImageSection> {
  final _pageController = PageController();
  int currentPage = 0;
  final Map<String, BoxFit> _imageFits = {};

  @override
  void initState() {
    super.initState();
    _resolveImageDimensions();
  }

  void _resolveImageDimensions() {
    for (final url in widget.product.imageUrl) {
      final provider = NetworkImage(url);
      provider
          .resolve(ImageConfiguration())
          .addListener(
            ImageStreamListener((ImageInfo info, bool _) {
              if (mounted) {
                setState(() {
                  _imageFits[url] = info.image.height > info.image.width
                      ? BoxFit.cover
                      : BoxFit.contain;
                });
              }
            }),
          );
    }
  }

  BoxFit _getFit(String url, bool isMobile) {
    if (!isMobile) return BoxFit.contain;
    return _imageFits[url] ?? BoxFit.contain;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (widget.product.imageUrl.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 20),
        child: Container(
          height: isMobile
              ? MediaQuery.of(context).size.height * 0.9
              : MediaQuery.of(context).size.height * 0.75,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 64,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 20),
      child: Column(
        spacing: 10,
        children: [
          SizedBox(
            height: isMobile
                ? MediaQuery.of(context).size.height * 0.75
                : MediaQuery.of(context).size.height * 0.75,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.product.imageUrl.length,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    final url = widget.product.imageUrl[index];
                    return SelectionContainer.disabled(
                      child: GestureDetector(
                        onDoubleTap: () => _openZoomDialog(context, url),
                        child: CatalogImage(
                          optimizedWidth: 800,
                          imageUrl: url,
                          fit: _getFit(url, isMobile),
                        ),
                      ),
                    );
                  },
                ),
                if (!isMobile) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          if (_pageController.hasClients) {
                            int nextPage = _pageController.page!.toInt() - 1;
                            if (nextPage < 0) {
                              nextPage = widget.product.imageUrl.length - 1;
                            }
                            _pageController.animateToPage(
                              nextPage,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        icon: Icon(Icons.arrow_back_ios_rounded),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          if (_pageController.hasClients) {
                            int nextPage = _pageController.page!.toInt() + 1;
                            if (nextPage >= widget.product.imageUrl.length) {
                              nextPage = 0;
                            }
                            _pageController.animateToPage(
                              nextPage,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        icon: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: widget.product.imageUrl.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == currentPage;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CatalogImage(
                            optimizedWidth: 150,
                            imageUrl: widget.product.imageUrl[index],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openZoomDialog(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: const Color.fromARGB(150, 0, 0, 0),
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      clipBehavior: Clip.none,
                      minScale: 1.0,
                      maxScale: 5.0,
                      child: CatalogImage(
                        optimizedWidth: 1200,
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SafeArea(
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
