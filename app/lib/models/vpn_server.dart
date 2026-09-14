import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A selectable VPN exit location.
class VpnServer {
  final String id;
  final String country;
  final String city;
  final String countryCode; // ISO 3166-1 alpha-2, for the flag widget
  final String ip;
  final int pingMs;
  final bool isPremium;
  final List<Color> cardGradient;

  const VpnServer({
    required this.id,
    required this.country,
    required this.city,
    required this.countryCode,
    required this.ip,
    required this.pingMs,
    this.isPremium = false,
    this.cardGradient = AppColors.cardBlue,
  });

  /// Signal quality bucket derived from ping (for the little bars UI).
  int get signalBars {
    if (pingMs < 60) return 3;
    if (pingMs < 120) return 2;
    return 1;
  }
}
