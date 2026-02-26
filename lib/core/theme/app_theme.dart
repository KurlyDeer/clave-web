import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color terracotta = Color(0xFFD35400);
  static const Color deepBlue = Color(0xFF2E86C1);
  static const Color cream = Color(0xFFFDF6EC);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color lightText = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color selectedBorder = Color(0xFFD35400);
  static const Color unselectedBorder = Color(0xFFD8D8D8);
  static const Color shadow = Color(0x1A000000);

  // ── Liquid Glass palette ───────────────────────────────────────────────────
  static const Color glassGradientStart = Color(0xFF0D1B3E); // deep navy
  static const Color glassGradientMid   = Color(0xFF1A1045); // deep indigo
  static const Color glassGradientEnd   = Color(0xFF2D1B69); // deep purple
  static const Color glassSurface       = Color(0x26FFFFFF); // 15% white
  static const Color glassBorder        = Color(0x4DFFFFFF); // 30% white
  static const Color glassHighlight     = Color(0x1AFFFFFF); // 10% white
  static const Color glowTerracotta     = Color(0xFFE67E22); // bright terracotta
  static const Color glassText          = Color(0xFFEEEEEE); // light text
  static const Color glassTextMuted     = Color(0xAAFFFFFF); // 67% white
}

class AppFontSizes {
  AppFontSizes._();

  static const double body = 18.0;
  static const double subtitle = 20.0;
  static const double title = 26.0;
  static const double headline = 32.0;

  // Senior Mode overrides (applied when Abuelo persona is active)
  static const double bodyLarge = 24.0;
  static const double subtitleLarge = 26.0;
  static const double titleLarge = 32.0;
  static const double headlineLarge = 38.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.terracotta,
        primary: AppColors.terracotta,
        secondary: AppColors.deepBlue,
        surface: AppColors.cream,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: AppFontSizes.headline,
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: AppFontSizes.title,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w400,
          color: AppColors.darkText,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: AppFontSizes.body,
          color: AppColors.darkText,
        ),
        labelLarge: TextStyle(
          fontSize: AppFontSizes.subtitle,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.terracotta,
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSizes.subtitle,
            fontWeight: FontWeight.w700,
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
