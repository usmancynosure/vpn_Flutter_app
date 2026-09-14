import 'package:flutter/material.dart';

/// Central color tokens for Shield VPN.
/// Matches the reference: soft lavender canvas, indigo accent, pastel tiles.
class AppColors {
  AppColors._();

  // Canvas & surfaces
  static const Color background = Color(0xFFECEBFA);
  static const Color backgroundAlt = Color(0xFFE7E6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F4FB);

  // Brand / accent
  static const Color primary = Color(0xFF5A4FF3);
  static const Color primaryDeep = Color(0xFF4A3FE0);
  static const Color primarySoft = Color(0xFFB9B2FF);

  // Text
  static const Color textPrimary = Color(0xFF191A32);
  static const Color textMuted = Color(0xFF8A8AA3);
  static const Color textFaint = Color(0xFFB4B4C8);

  // Status
  static const Color connected = Color(0xFF22C55E);
  static const Color disconnected = Color(0xFFEF5A6F);

  // Dark hero (servers screen globe card)
  static const Color heroDark = Color(0xFF0A0B1E);
  static const Color heroGlow = Color(0xFF2E6BFF);

  // Pastel stat-tile gradients
  static const List<Color> tileBlue = [Color(0xFFDCE4FF), Color(0xFFEADEFF)];
  static const List<Color> tileGreen = [Color(0xFFD3F5E1), Color(0xFFE9FAF0)];
  static const List<Color> tilePink = [Color(0xFFFDDCE5), Color(0xFFFCEAF1)];
  static const List<Color> tilePeach = [Color(0xFFFCE7CE), Color(0xFFFDF3E4)];

  // Server-card gradients
  static const List<Color> cardRed = [Color(0xFFFDE0E4), Color(0xFFF7C9D4)];
  static const List<Color> cardGreen = [Color(0xFFD9F5E4), Color(0xFFC6EED8)];
  static const List<Color> cardBlue = [Color(0xFFDCE6FF), Color(0xFFC8D6FB)];
  static const List<Color> cardPurple = [Color(0xFFE6DEFF), Color(0xFFD3C6FB)];
}
