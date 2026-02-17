import 'package:flutter/material.dart';

class FilterCatalogView extends StatelessWidget {
  const FilterCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [Placeholder()]),
      ),
    );
  }
}
