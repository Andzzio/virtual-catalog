import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/banner_image.dart';
import 'package:virtual_catalog_app/presentation/widgets/home_grid_products.dart';
import 'package:virtual_catalog_app/presentation/widgets/home_list_products.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;
  @override
  Widget build(BuildContext context) {
    final ProductProvider provider = context.watch<ProductProvider>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
        toolbarHeight: 65,
        leadingWidth: size.width * 0.1,
        centerTitle: true,
        leading: Center(
          child: Text(
            "VIRTUAL CATALOG",
            style: GoogleFonts.getFont(
              FontNames.fontNameH1,
              textStyle: TextStyle(
                color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
                fontWeight: FontWeight.bold,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                "Inicio",
                style: GoogleFonts.getFont(
                  FontNames.fontNameP,
                  textStyle: TextStyle(
                    color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {},
              child: Text(
                "Catálogo",
                style: GoogleFonts.getFont(
                  FontNames.fontNameP,
                  textStyle: TextStyle(
                    color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: size.width * 0.15,
            height: 40,
            child: TextField(
              style: TextStyle(
                color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                prefixIconColor: Color(0xFFB3B8C1),

                hintText: "Buscar...",
                hintStyle: GoogleFonts.getFont(
                  FontNames.fontNameP,
                  textStyle: TextStyle(color: Color(0xFFB3B8C1)),
                ),

                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB3B8C1)),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.shopping_cart_rounded,
              color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
            ),
          ),
          SizedBox(width: 20),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.person_2_rounded,
              color: _isScrolled ? Colors.black : Color(0xFFB3B8C1),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: CircleBorder(),
        backgroundColor: Colors.greenAccent,
        child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            BannerImage(size: size),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                  HomeListProducts(provider: provider),
                  SizedBox(height: 50),
                  HomeGridProducts(provider: provider),
                  SizedBox(height: 50),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: Center(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("© 2026 Virtual Catalog"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 1 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 1 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
