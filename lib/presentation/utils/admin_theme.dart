import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';

/// Design tokens for the Admin Panel — Dark Modern Theme.
/// Following "make-interfaces-feel-better" skill principles:
/// - Shadows over borders for depth
/// - Concentric border radius
/// - Tabular nums for dynamic numbers
/// - Minimum 40×40 hit areas
class AdminTheme {
  AdminTheme._();

  // ─── Core Dark Palette ─────────────────────────────────
  static const Color surface = Color(0xFF0F172A);       // slate-900
  static const Color cardBg = Color(0xFF1E293B);        // slate-800
  static const Color cardBgElevated = Color(0xFF253349); // slightly lighter
  static const Color border = Color(0xFF334155);         // slate-700
  static const Color inputFill = Color(0xFF1E293B);      // same as card

  // ─── Sidebar Colors ───────────────────────────────────
  static const Color sidebarBg = Color(0xFF0B1120);     // deeper than surface
  static const Color sidebarText = Color(0xFFE2E8F0);
  static const Color sidebarTextMuted = Color(0xFF64748B);

  // ─── Text Colors ──────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);   // slate-100
  static const Color textSecondary = Color(0xFF94A3B8);  // slate-400
  static const Color textMuted = Color(0xFF64748B);      // slate-500

  // ─── Semantic Colors ──────────────────────────────────
  static const Color accent = Color(0xFF3B82F6);         // blue-500
  static const Color accentLight = Color(0xFF60A5FA);    // blue-400
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Shadows (skill: shadows for depth on dark) ───────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
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

  /// Tabular figures style for dynamic numbers (skill: tabular-nums)
  static TextStyle kpiValue() => GoogleFonts.getFont(
    FontNames.fontNameH2,
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  // ─── Dark Theme Override for Admin Panel ──────────────
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.dark(
      surface: cardBg,
      primary: accent,
      error: danger,
      onSurface: textPrimary,
      onPrimary: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cardBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: heading2(),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    dividerColor: border,
    dividerTheme: DividerThemeData(
      color: border.withValues(alpha: 0.5),
      thickness: 0.5,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accent.withValues(alpha: 0.3);
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

  // ─── Shared Input Decoration ──────────────────────────
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

  // ─── Card Decoration (skill: shadows over borders) ────
  static BoxDecoration cardDecoration({bool elevated = true}) {
    return BoxDecoration(
      color: elevated ? cardBgElevated : cardBg,
      borderRadius: BorderRadius.circular(radiusMd),
      boxShadow: elevated ? cardShadow : null,
      border: Border.all(color: border, width: 0.5),
    );
  }

  // ─── Button Styles ────────────────────────────────────
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
