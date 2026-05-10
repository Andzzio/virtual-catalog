import 'package:flutter/material.dart';

List<Color> colors = [Colors.blueAccent, Colors.redAccent, Colors.greenAccent];

class ThemeConfig {
  final int selectedColor;
  final Color? customColor;
  final Color? customBgColor;

  ThemeConfig({
    required this.selectedColor,
    this.customColor,
    this.customBgColor,
  }) : assert(
          selectedColor >= 0 && selectedColor < colors.length,
          "Index out of range $selectedColor, ${colors.length}",
        );

  ThemeData getTheme() {
    final baseColor = customColor ?? colors[selectedColor];
    final colorScheme = ColorScheme.fromSeed(
      seedColor: baseColor,
      primary: baseColor,
      surface: customBgColor,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: customBgColor ?? colorScheme.surface,
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
