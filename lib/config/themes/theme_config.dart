import 'package:flutter/material.dart';

List<Color> colors = [Colors.blueAccent];

class ThemeConfig {
  final int selectedColor;
  ThemeConfig({required this.selectedColor})
    : assert(
        selectedColor >= 0 && selectedColor < colors.length,
        "Index out of range",
      );
  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: colors[selectedColor],
    );
  }
}
