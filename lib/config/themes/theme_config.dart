import 'package:flutter/material.dart';

List<Color> colors = [Colors.blueAccent, Colors.redAccent, Colors.greenAccent];

class ThemeConfig {
  final int selectedColor;
  ThemeConfig({required this.selectedColor})
    : assert(
        selectedColor >= 0 && selectedColor < colors.length,
        "Index out of range $selectedColor, ${colors.length}",
      );
  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: colors[selectedColor],
    );
  }
}
