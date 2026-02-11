import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class BannerImage extends StatefulWidget {
  const BannerImage({super.key, required this.size});

  final Size size;

  @override
  State<BannerImage> createState() => _BannerImageState();
}

class _BannerImageState extends State<BannerImage> {
  final _pageController = PageController();
  final int _pageCount = 5;
  Timer? _timer;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.size.height,
      decoration: BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pageCount,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/banner_catalogo_large.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                        stops: [0.5, 1],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "VIRTUAL CATALOG",
                            style: GoogleFonts.getFont(
                              FontNames.fontNameH1,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 72,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: widget.size.width * 0.5,
                            child: Text(
                              "La colección 2026. Descubre la textura del lujo moderno definida por la silueta y la gracia.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pageCount,
                effect: ExpandingDotsEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 10,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Colors.white,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.toInt() + 1;
        if (nextPage >= _pageCount) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
