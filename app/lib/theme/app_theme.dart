import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App-wide theme. Headings use Outfit (geometric), body uses Work Sans.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.workSansTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.workSans(
        fontSize: 14,
        color: AppColors.textMuted,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
