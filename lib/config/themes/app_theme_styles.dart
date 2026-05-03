import 'package:flutter/material.dart';

class AppBorders {
  static const double radiusCard = 12.0;
  static const double radiusButton = 8.0;
  static const double radiusInput = 8.0;
  static const double radiusImage = 10.0;
  static const double radiusPill = 20.0;
}

class AppShadows {
  static final BoxShadow soft = BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  static final BoxShadow hover = BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );

  static final BoxShadow navbar = BoxShadow(
    color: Colors.black.withValues(alpha: 0.03),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}

class AppPaddings {
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;

  // Padding global para la app
  static const EdgeInsets screenMobile = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 20.0,
  );
  static const EdgeInsets screenWeb = EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 24.0,
  );
}

class AppColors {
  static const Color background = Color(0xFFFAFAFA); // Gris nieve ultra premium
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro
  static const Color textDark = Color(0xFF111827); // Gris casi negro
  static const Color textMuted = Color(0xFF4B5563); // Gris medio
  static const Color textLight = Color(0xFF9CA3AF); // Gris claro
  static const Color border = Color(0xFFE5E7EB); // Borde ultra sutil
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
}
