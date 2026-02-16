import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';

class BannerImage extends StatefulWidget {
  const BannerImage({super.key, required this.size});

  final Size size;

  @override
  State<BannerImage> createState() => _BannerImageState();
}

class _BannerImageState extends State<BannerImage> {
  final _pageController = PageController();
  Timer? _timer;
  int _bannerCount = 0;
  @override
  Widget build(BuildContext context) {
    final businessProvider = context.watch<BusinessProvider>();
    final banners = businessProvider.business?.banners ?? [];
    _bannerCount = banners.length;
    if (banners.isEmpty) return SizedBox(height: widget.size.height);
    return Container(
      width: double.infinity,
      height: widget.size.height,
      decoration: BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      banners[index].imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                        stops: [0, 0.2],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
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
                            banners[index].title,
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
                              banners[index].subtitle,
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
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: banners.length,
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
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _bannerCount > 0) {
        int nextPage = _pageController.page!.toInt() + 1;
        if (nextPage >= _bannerCount) {
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
