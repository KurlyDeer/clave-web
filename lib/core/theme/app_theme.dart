import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // ── Portfolio Hexes ────────────────────────────────────────────────────────
  static const Color emeraldBase = Color(0xFF10B981); // emerald-500
  static const Color emeraldHighlight = Color(0xFF34D399); // emerald-400

  static const Color terracotta = Color(0xFFF59E0B); // Mapped to amber-500
  static const Color deepBlue = Color(0xFF0EA5E9); // sky-500
  static const Color cream = Color(0xFFF8F9FA); // light background
  static const Color darkText = Color(0xFF111111); // zinc-950 text
  static const Color lightText = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color selectedBorder = Color(0xFFF59E0B); // amber-500
  static const Color unselectedBorder = Color(0xFFD4D4D8); // zinc-300
  static const Color shadow = Color(0x1A000000);

  // ── Liquid Glass palette ───────────────────────────────────────────────────
  static bool _isDark = true;
  static void setDarkMode(bool v) => _isDark = v;

  static Color get glassGradientStart =>
      _isDark ? const Color(0xFF09090B) : const Color(0xFFF8F9FA); // zinc-950 / light
  static Color get glassGradientMid =>
      _isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF); // zinc-900 / white
  static Color get glassGradientEnd =>
      _isDark ? const Color(0xFF09090B) : const Color(0xFFFFFFFF); // zinc-950 / white
  static Color get glassSurface =>
      _isDark ? const Color(0xB318181B) : const Color(0xD9FFFFFF); // bg-zinc-900/70 / bg-white/85
  static Color get glassBorder =>
      _isDark ? const Color(0xCC27272A) : const Color(0x99D4D4D8); // border-zinc-800/80 / border-zinc-300/60
  static Color get glassHighlight =>
      _isDark ? const Color(0x1AFFFFFF) : const Color(0x0D000000);
  static Color get glassText =>
      _isDark ? const Color(0xFFE4E4E7) : const Color(0xFF111111); // text-zinc-200 / text-zinc-950
  static Color get glassTextMuted =>
      _isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A); // text-zinc-400 / text-zinc-500

  static const Color glowTerracotta = Color(0xFFF59E0B); // Amber

  // ── Semantic colors ───────────────────────────────────────────────────────
  static const Color premiumGold  = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed     = Color(0xFFF43F5E);

  // ── Difficulty level colors ───────────────────────────────────────────────
  static const Color difficultyA1 = Color(0xFF10B981); // Emerald
  static const Color difficultyA2 = Color(0xFF0EA5E9); // Sky
  static const Color difficultyB1 = Color(0xFFF43F5E); // Rose
}

class AppFontSizes {
  AppFontSizes._();

  static const double body = 16.0; // Scaled down slightly to match web standard
  static const double subtitle = 18.0;
  static const double title = 24.0;
  static const double headline = 32.0;

  // Senior Mode overrides (applied when Abuelo persona is active)
  static const double bodyLarge = 22.0;
  static const double subtitleLarge = 24.0;
  static const double titleLarge = 30.0;
  static const double headlineLarge = 36.0;
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
    border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.25),
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

  static TextStyle glassTitle({bool isSenior = false}) => GoogleFonts.spaceGrotesk(
    fontSize: isSenior ? AppFontSizes.titleLarge : AppFontSizes.title,
    fontWeight: FontWeight.w700,
    color: AppColors.glassText,
  );

  static TextStyle glassBody({bool isSenior = false}) => GoogleFonts.inter(
    fontSize: isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
    color: AppColors.glassText,
    height: 1.5,
  );

  static TextStyle glassMuted({bool isSenior = false}) => GoogleFonts.inter(
    fontSize: isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
    color: AppColors.glassTextMuted,
    height: 1.5,
  );

  static TextStyle difficultyBadge(Color color) => GoogleFonts.jetBrainsMono(
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
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: AppFontSizes.headline,
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: AppFontSizes.title,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w400,
          color: AppColors.darkText,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: AppFontSizes.body,
          color: AppColors.darkText,
        ),
        labelLarge: GoogleFonts.inter(
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
            borderRadius: BorderRadius.circular(12), // Matching rounded-xl
          ),
          textStyle: GoogleFonts.spaceGrotesk(
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
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: AppFontSizes.headline,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFE4E4E7),
          height: 1.2,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: AppFontSizes.title,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFE4E4E7),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFE4E4E7),
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: AppFontSizes.body,
          color: const Color(0xFFE4E4E7),
        ),
        labelLarge: GoogleFonts.inter(
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
            borderRadius: BorderRadius.circular(12), // Matching rounded-xl
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: AppFontSizes.subtitle,
            fontWeight: FontWeight.w700,
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
