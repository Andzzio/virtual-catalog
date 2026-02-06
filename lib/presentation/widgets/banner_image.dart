import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  const BannerImage({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 800,
      decoration: BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/banner_catalog.png",
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
                    "Autumn Ethereal",
                    style: TextStyle(color: Colors.white, fontSize: 72),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: size.width * 0.5,
                    child: Text(
                      "The 2026 Collection. Discover the texture of modern luxury defined by silhouette and grace.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
