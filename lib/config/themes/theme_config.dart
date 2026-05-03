import 'package:flutter/material.dart';

List<Color> colors = [Colors.blueAccent, Colors.redAccent, Colors.greenAccent];

class ThemeConfig {
  final int selectedColor;
  final Color? customColor;

  ThemeConfig({required this.selectedColor, this.customColor})
      : assert(
          selectedColor >= 0 && selectedColor < colors.length,
          "Index out of range $selectedColor, ${colors.length}",
        );

  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: customColor ?? colors[selectedColor],
    );
  }

  static Color? hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return null;
    }
  }
}
