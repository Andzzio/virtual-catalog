import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';

class ProductImageSection extends StatefulWidget {
  final Product product;
  const ProductImageSection({super.key, required this.product});

  @override
  State<ProductImageSection> createState() => _ProductImageSectionState();
}

class _ProductImageSectionState extends State<ProductImageSection> {
  final _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Row(
              children: [
                IconButton(
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
                Expanded(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.product.imageUrl.length,
                        itemBuilder: (context, index) {
                          return Image.asset(widget.product.imageUrl[index]);
                        },
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: widget.product.imageUrl.length,
                            effect: ExpandingDotsEffect(
                              activeDotColor: Colors.white,
                              dotHeight: 10,
                              dotWidth: 10,
                              spacing: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
