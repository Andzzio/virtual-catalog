import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

class AdminTheme {
  AdminTheme._();

  static const Color surface = Color(0xFFF2F8F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBgElevated = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD1E2DD);
  static const Color inputFill = Color(0xFFFFFFFF);

  static const Color sidebarBg = Color(0xFF1E2D4A);
  static const Color sidebarText = Color(0xFFFFFFFF);
  static const Color sidebarTextMuted = Color(0xFF8FA3C7);

  static const Color textPrimary = Color(0xFF1E2D4A);
  static const Color textSecondary = Color(0xFF4A7A99);
  static const Color textMuted = Color(0xFF7A8F9E);

  static const Color accent = Color(0xFFE23D47);
  static const Color accentLight = Color(0xFFFFA5A9);
  static const Color danger = Color(0xFFE23D47);
  static const Color success = Color(0xFF2E8B57);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF4A7A99);

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  // ─── Border Radius ────────────────────────────────────
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;

  // ─── Breakpoints (skill: LayoutBuilder based) ─────────
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;

  // ─── Sidebar ──────────────────────────────────────────
  static const double sidebarWidth = 260.0;

  // ─── Typography ───────────────────────────────────────
  static TextStyle heading1() => GoogleFonts.getFont(
    FontNames.fontNameH2,
    textStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
  );

  static TextStyle heading2() => GoogleFonts.getFont(
    FontNames.fontNameH2,
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
  );

  static TextStyle body() => GoogleFonts.getFont(
    FontNames.fontNameH2,
    textStyle: const TextStyle(fontSize: 14, color: textPrimary),
  );

  static TextStyle bodySmall() => GoogleFonts.getFont(
    FontNames.fontNameH2,
    textStyle: const TextStyle(fontSize: 13, color: textSecondary),
  );

  static TextStyle caption() => GoogleFonts.getFont(
    FontNames.fontNameH2,
    textStyle: const TextStyle(fontSize: 12, color: textMuted),
  );

  static TextStyle kpiValue() => GoogleFonts.getFont(
    FontNames.fontNameH2,
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  static TextStyle appBarTitle() => GoogleFonts.getFont(
    FontNames.fontNameH2,
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  static TextStyle appBarSubtitle() => GoogleFonts.getFont(
    FontNames.fontNameH2,
    textStyle: const TextStyle(
      fontSize: 13,
      color: sidebarTextMuted,
    ),
  );

  static ThemeData get darkTheme => ThemeData.light().copyWith(
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.light(
      surface: cardBg,
      primary: accent,
      error: danger,
      onSurface: textPrimary,
      onPrimary: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: sidebarBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: appBarTitle(),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    dividerColor: border,
    dividerTheme: DividerThemeData(
      color: border.withValues(alpha: 0.3),
      thickness: 0.5,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return success;
        return textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return success.withValues(alpha: 0.2);
        }
        return border;
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(cardBgElevated),
      ),
      textStyle: body(),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardBgElevated,
      contentTextStyle: body(),
    ),
  );

  static InputDecoration inputDecoration({
    String hintText = "",
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.getFont(
        FontNames.fontNameH2,
        textStyle: TextStyle(color: textMuted, fontSize: 14),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: danger, width: 1.5),
      ),
    );
  }

  static BoxDecoration cardDecoration({bool elevated = true}) {
    return BoxDecoration(
      color: elevated ? cardBgElevated : cardBg,
      borderRadius: BorderRadius.circular(radiusMd),
      boxShadow: elevated ? cardShadow : null,
      border: Border.all(color: border, width: 0.5),
    );
  }

  static ButtonStyle primaryButton() => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    backgroundColor: accent,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );

  static ButtonStyle outlinedButton() => OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    foregroundColor: textPrimary,
    side: const BorderSide(color: border),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );
}
