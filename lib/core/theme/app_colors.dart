import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1E3A8A); // Deep Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Light Blue
  static const Color primaryDark = Color(0xFF1E40AF); // Darker Blue

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Green
  static const Color secondaryLight = Color(0xFF34D399); // Light Green
  static const Color secondaryDark = Color(0xFF059669); // Dark Green

  // Background Colors
  static const Color background = Color(0xFFF0F4FF); // Very Light Blue
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF8FAFC); // Off White

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // Dark Gray
  static const Color textSecondary = Color(0xFF64748B); // Medium Gray
  static const Color textTertiary = Color(0xFF94A3B8); // Light Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  // Mood Colors
  static const Color moodVeryHappy = Color(0xFFEAB308); // Yellow
  static const Color moodHappy = Color(0xFF22C55E); // Green
  static const Color moodNeutral = Color(0xFF6B7280); // Gray
  static const Color moodSad = Color(0xFFEF4444); // Red
  static const Color moodVerySad = Color(0xFF991B1B); // Dark Red

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Shadow Colors
  static const Color shadow = Color(0x1A000000); // 10% Black
  static const Color shadowLight = Color(0x0D000000); // 5% Black
  static const Color shadowDark = Color(0x33000000); // 20% Black

  // Border Colors
  static const Color border = Color(0xFFE2E8F0); // Light Gray
  static const Color borderFocus = Color(0xFF3B82F6); // Blue
  static const Color borderError = Color(0xFFEF4444); // Red

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF0F4FF), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient moodGradient = LinearGradient(
    colors: [Color(0xFFEAB308), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Mood Color Mapping
  static Color getMoodColor(String moodType) {
    switch (moodType) {
      case 'very_happy':
        return moodVeryHappy;
      case 'happy':
        return moodHappy;
      case 'neutral':
        return moodNeutral;
      case 'sad':
        return moodSad;
      case 'very_sad':
        return moodVerySad;
      default:
        return moodNeutral;
    }
  }

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Orange
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF84CC16), // Lime
  ];

  // Opacity Variations
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Material Color Swatches
  static const MaterialColor primarySwatch =
      MaterialColor(0xFF1E3A8A, <int, Color>{
        50: Color(0xFFEFF6FF),
        100: Color(0xFFDBEAFE),
        200: Color(0xFFBFDBFE),
        300: Color(0xFF93C5FD),
        400: Color(0xFF60A5FA),
        500: Color(0xFF3B82F6),
        600: Color(0xFF2563EB),
        700: Color(0xFF1D4ED8),
        800: Color(0xFF1E40AF),
        900: Color(0xFF1E3A8A),
      });
}
