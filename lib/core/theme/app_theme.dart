import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color emeraldBase = Color(0xFF10B981);
  static const Color emeraldHighlight = Color(0xFF34D399);

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
  static bool _isDark = true;
  static void setDarkMode(bool v) => _isDark = v;

  static Color get glassGradientStart =>
      _isDark ? const Color(0xFF09090B) : const Color(0xFFFFFFFF);
  static Color get glassGradientMid =>
      _isDark ? const Color(0xFF09090B) : const Color(0xFFFFFFFF);
  static Color get glassGradientEnd =>
      _isDark ? const Color(0xFF09090B) : const Color(0xFFFFFFFF);
  static Color get glassSurface =>
      _isDark ? const Color(0x26FFFFFF) : const Color(0x12000000);
  static Color get glassBorder =>
      _isDark ? const Color(0x4DFFFFFF) : const Color(0x1F000000);
  static Color get glassHighlight =>
      _isDark ? const Color(0x1AFFFFFF) : const Color(0x0D000000);
  static Color get glassText =>
      _isDark ? const Color(0xFFEEEEEE) : const Color(0xFF1A1A1A);
  static Color get glassTextMuted =>
      _isDark ? const Color(0xAAFFFFFF) : const Color(0x99000000);

  static const Color glowTerracotta = Color(0xFFE67E22); // bright terracotta

  // ── Semantic colors ───────────────────────────────────────────────────────
  static const Color premiumGold  = Color(0xFFF39C12);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color warningAmber = Color(0xFFF39C12);
  static const Color errorRed     = Color(0xFFE74C3C);

  // ── Difficulty level colors ───────────────────────────────────────────────
  static const Color difficultyA1 = Color(0xFF27AE60); // green
  static const Color difficultyA2 = Color(0xFF2E86C1); // blue
  static const Color difficultyB1 = Color(0xFF8E44AD); // purple
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

// ── AppGlassStyles ─────────────────────────────────────────────────────────

class AppGlassStyles {
  AppGlassStyles._();

  static Gradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.glassGradientStart,
      AppColors.glassGradientMid,
      AppColors.glassGradientEnd,
    ],
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.glassSurface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.glassBorder),
  );

  static BoxDecoration glowBorder(Color color) => BoxDecoration(
    color: AppColors.glassSurface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: color.withOpacity(0.7), width: 2),
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.25),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ],
  );

  static Color difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'A1':
        return AppColors.difficultyA1;
      case 'A2':
        return AppColors.difficultyA2;
      case 'B1':
        return AppColors.difficultyB1;
      default:
        return AppColors.difficultyA1;
    }
  }
}

// ── AppTextStyles ─────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static TextStyle glassTitle({bool isSenior = false}) => TextStyle(
    fontSize: isSenior ? AppFontSizes.titleLarge : AppFontSizes.title,
    fontWeight: FontWeight.w700,
    color: AppColors.glassText,
  );

  static TextStyle glassBody({bool isSenior = false}) => TextStyle(
    fontSize: isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
    color: AppColors.glassText,
    height: 1.5,
  );

  static TextStyle glassMuted({bool isSenior = false}) => TextStyle(
    fontSize: isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
    color: AppColors.glassTextMuted,
    height: 1.4,
  );

  static TextStyle difficultyBadge(Color color) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: 0.5,
  );
}

// ── AppTheme ──────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emeraldBase,
        primary: AppColors.emeraldBase,
        secondary: AppColors.emeraldHighlight,
        surface: const Color(0xFFF8F9FA),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
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
          backgroundColor: AppColors.emeraldBase,
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

  static ThemeData get dark {
    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emeraldBase,
        primary: AppColors.emeraldBase,
        secondary: AppColors.emeraldHighlight,
        surface: const Color(0xFF070708),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF09090B),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.emeraldBase,
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
