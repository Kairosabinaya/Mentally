import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Base Theme
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        surfaceVariant: AppColors.surfaceVariant,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
        outline: AppColors.border,
      ),

      // Primary Swatch
      primarySwatch: AppColors.primarySwatch,

      // Scaffold Theme
      scaffoldBackgroundColor: AppColors.background,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderError, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontFamily: 'Poppins',
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.textTertiary,
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(
          color: AppColors.textOnPrimary,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.border;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.textOnPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
      ),

      // Slider Theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primaryLight,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ListTile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        subtitleTextStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
      ),

      // Font Family
      fontFamily: 'Poppins',
    );
  }

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display Styles
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),

      // Headline Styles
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),

      // Title Styles
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),

      // Body Styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        fontFamily: 'Poppins',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        fontFamily: 'Poppins',
      ),

      // Label Styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        fontFamily: 'Poppins',
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        fontFamily: 'Poppins',
      ),
    );
  }

  // Custom Text Styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Poppins',
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: 'Poppins',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    fontFamily: 'Poppins',
  );
}
