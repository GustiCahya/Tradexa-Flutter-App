import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Colors.black;
  static const Color surface = Color(
    0x0CFFFFFF,
  ); // ~5% white (translucent, for cards/inputs)
  static const Color surfaceSolid = Color(
    0xFF1E1E1E,
  ); // Opaque dark gray (for popups, menus, snackbars)
  static const Color border = Color(0x1AFFFFFF); // ~10% white

  // Overlays
  static const Color surfaceHover = Color(0x14FFFFFF); // ~8% white

  // Typography
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Accents
  static const Color brandPrimary = Color(0xFF3B82F6);
  static const Color brandPrimaryLight = Color(0xFF60A5FA);

  static const Color success = Color(
    0xFF3B82F6,
  ); // Design system maps success to blue
  static const Color successLight = Color(0xFF60A5FA);

  static const Color danger = Color(0xFFF97316); // Orange for losing/short
  static const Color dangerLight = Color(0xFFFB923C);

  static const Color secondaryAccent = Color(0xFFA855F7); // Purple
  static const Color secondaryAccentLight = Color(0xFFC084FC);
}
