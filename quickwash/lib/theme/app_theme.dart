import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core surfaces
  static const Color surface = Color(0xFF0E1322);
  static const Color surfaceDim = Color(0xFF0E1322);
  static const Color surfaceBright = Color(0xFF343949);
  static const Color surfaceContainerLowest = Color(0xFF090E1C);
  static const Color surfaceContainerLow = Color(0xFF161B2B);
  static const Color surfaceContainer = Color(0xFF1A1F2F);
  static const Color surfaceContainerHigh = Color(0xFF25293A);
  static const Color surfaceContainerHighest = Color(0xFF2F3445);
  static const Color surfaceVariant = Color(0xFF2F3445);

  // On-surface
  static const Color onSurface = Color(0xFFDEE1F7);
  static const Color onSurfaceVariant = Color(0xFFC2C6D4);

  // Primary
  static const Color primary = Color(0xFFAAC7FF);
  static const Color onPrimary = Color(0xFF002F64);
  static const Color primaryContainer = Color(0xFF1A6BCC);
  static const Color onPrimaryContainer = Color(0xFFEAEFFF);

  // Secondary (Cyan)
  static const Color secondary = Color(0xFF4CD7F6);
  static const Color onSecondary = Color(0xFF003640);
  static const Color secondaryContainer = Color(0xFF03B5D3);
  static const Color onSecondaryContainer = Color(0xFF00424E);

  // Tertiary (Purple)
  static const Color tertiary = Color(0xFFD0BCFF);
  static const Color onTertiary = Color(0xFF3C0091);
  static const Color tertiaryContainer = Color(0xFF7C4CE6);
  static const Color onTertiaryContainer = Color(0xFFF5ECFF);

  // Error
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);

  // Outline
  static const Color outline = Color(0xFF8C919E);
  static const Color outlineVariant = Color(0xFF424752);

  // Background
  static const Color background = Color(0xFF0E1322);
  static const Color onBackground = Color(0xFFDEE1F7);

  // Glass effects
  static const Color glassWhite6 = Color(0x0FFFFFFF);  // rgba(255,255,255,0.06)
  static const Color glassWhite10 = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const Color glassBorder = Color(0x1FFFFFFF);  // rgba(255,255,255,0.12)
  static const Color glassInput = Color(0x0AFFFFFF);   // rgba(255,255,255,0.04)

  // Gradient colors
  static const Color gradientBlueStart = Color(0xFF1A6BCC);
  static const Color gradientCyanEnd = Color(0xFF06B6D4);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 40 / 32,
          letterSpacing: -0.64,
          color: AppColors.onSurface,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 34 / 28,
          letterSpacing: -0.28,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 30 / 24,
          color: AppColors.onSurface,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 28 / 20,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          height: 26 / 17,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 22 / 15,
          color: AppColors.onSurface,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 18 / 13,
          letterSpacing: 0.13,
          color: AppColors.onSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 16 / 11,
          letterSpacing: 0.33,
          color: AppColors.onSurface,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.onSurfaceVariant,
      ),
    );
  }
}
