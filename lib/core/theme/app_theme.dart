import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Base corner radius for the sharp, minimal shape language (cards, chips).
const double kRadiusSm = 4.0;

/// Larger radius used for product / 3D-preview cards and image containers.
const double kRadiusLg = 12.0;

/// Size selectors and text inputs are square — no rounding at all.
const double kRadiusNone = 0.0;

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color color) {
    final base = GoogleFonts.archivoTextTheme();
    return base
        .apply(bodyColor: color, displayColor: color)
        .copyWith(
          displayLarge: GoogleFonts.archivo(
            fontWeight: FontWeight.w800,
            fontSize: 96,
            height: 0.88,
            letterSpacing: -0.045 * 96,
            color: color,
          ),
          displayMedium: GoogleFonts.archivo(
            fontWeight: FontWeight.w800,
            fontSize: 64,
            height: 0.88,
            letterSpacing: -0.045 * 64,
            color: color,
          ),
          displaySmall: GoogleFonts.archivo(
            fontWeight: FontWeight.w800,
            fontSize: 40,
            height: 0.9,
            letterSpacing: -0.045 * 40,
            color: color,
          ),
          bodyLarge: GoogleFonts.archivo(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 1.6,
            color: color,
          ),
          bodyMedium: GoogleFonts.archivo(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.6,
            color: color,
          ),
        );
  }

  static ThemeData get light {
    final colorScheme = const ColorScheme.light().copyWith(
      surface: AppColors.background,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.foreground,
      error: AppColors.destructive,
      onError: AppColors.primaryForeground,
      onSurface: AppColors.foreground,
      outline: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      fontFamily: GoogleFonts.archivo().fontFamily,
      textTheme: _textTheme(AppColors.foreground),
      dividerColor: AppColors.border,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusNone),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusNone),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusNone),
          borderSide: const BorderSide(color: AppColors.foreground, width: 1.5),
        ),
        hintStyle: GoogleFonts.archivo(color: AppColors.mutedForeground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.mutedForeground,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.archivo(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: const BorderSide(color: AppColors.foreground, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.archivo(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.foreground,
          textStyle: GoogleFonts.archivo(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
        labelStyle: GoogleFonts.archivo(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.foreground,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
