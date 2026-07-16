import 'package:flutter/material.dart';

/// Brand palette for Happy Club. Warm, optimistic gradients paired with
/// calm neutrals so the product reads as premium rather than saccharine.
class AppColors {
  AppColors._();

  // Brand gradient anchors.
  static const Color sunrise = Color(0xFFFF8A65);
  static const Color coral = Color(0xFFFF6F91);
  static const Color amber = Color(0xFFFFC371);
  static const Color violet = Color(0xFF8E7CFF);
  static const Color skyBlue = Color(0xFF5AC8FA);
  static const Color mint = Color(0xFF3DD9B4);

  static const Color primary = Color(0xFFFF7A59);
  static const Color secondary = Color(0xFF6C63FF);
  static const Color tertiary = Color(0xFF3DD9B4);

  // Light theme neutrals.
  static const Color lightBackground = Color(0xFFFFF9F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFFFF1E8);
  static const Color lightOnSurface = Color(0xFF2A2233);
  static const Color lightOnSurfaceMuted = Color(0xFF7A7285);

  // Dark theme neutrals.
  static const Color darkBackground = Color(0xFF120F1B);
  static const Color darkSurface = Color(0xFF1D1929);
  static const Color darkSurfaceAlt = Color(0xFF261F36);
  static const Color darkOnSurface = Color(0xFFF3EEFF);
  static const Color darkOnSurfaceMuted = Color(0xFFB0A7C2);

  static const List<Color> heroGradient = [sunrise, coral];
  static const List<Color> calmGradient = [violet, skyBlue];
  static const List<Color> growthGradient = [mint, skyBlue];
  static const List<Color> goldGradient = [Color(0xFFFFD86B), amber];

  static const List<Color> moodColors = [
    Color(0xFF8E8EA6), // struggling
    Color(0xFF6C9BFF), // low
    Color(0xFF3DD9B4), // okay
    Color(0xFFFFC371), // good
    Color(0xFFFF7A59), // great
  ];

  static Color happinessColor(double score) {
    if (score >= 85) return const Color(0xFFFF7A59);
    if (score >= 65) return const Color(0xFFFFC371);
    if (score >= 40) return const Color(0xFF3DD9B4);
    return const Color(0xFF8E8EA6);
  }
}
