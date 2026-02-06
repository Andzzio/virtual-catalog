import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/presentation/widgets/banner_image.dart';
import 'package:virtual_catalog_app/presentation/widgets/home_grid_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        leadingWidth: size.width * 0.1,
        centerTitle: true,
        leading: Center(
          child: Text(
            "VIRTUAL CATALOG",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: Text("Home", style: TextStyle(color: Colors.black)),
            ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {},
              child: Text("Products", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: size.width * 0.15,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                prefixIconColor: Color(0xFFB3B8C1),
                hintText: "Search...",
                hintStyle: TextStyle(color: Color(0xFFB3B8C1)),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB3B8C1)),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart_rounded)),
          SizedBox(width: 20),
          IconButton(onPressed: () {}, icon: Icon(Icons.person_2_rounded)),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BannerImage(size: size),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(children: [HomeGridProducts()]),
            ),
          ],
        ),
      ),
    );
  }
}
