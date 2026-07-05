import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font.dart';

class AppTheme {
  // ==================================================
  // LIGHT THEME
  // ==================================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    textTheme: TextTheme(
      headlineLarge: AppFont.headingLarge,
      headlineMedium: AppFont.headingMedium,
      headlineSmall: AppFont.headingSmall,
      titleLarge: AppFont.titleLarge,
      titleMedium: AppFont.titleMedium,
      titleSmall: AppFont.titleSmall,
      bodyLarge: AppFont.bodyLarge,
      bodyMedium: AppFont.bodyMedium,
      bodySmall: AppFont.bodySmall,
      labelLarge: AppFont.labelLarge,
      labelMedium: AppFont.labelMedium,
      labelSmall: AppFont.labelSmall,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.textPrimary,
    ),

    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
  );

  // ==================================================
  // DARK THEME
  // ==================================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFF0F172A),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: Color(0xFF1E293B),
      error: AppColors.error,
    ),

    textTheme: TextTheme(
      headlineLarge: AppFont.headingLarge,
      headlineMedium: AppFont.headingMedium,
      headlineSmall: AppFont.headingSmall,
      titleLarge: AppFont.titleLarge,
      titleMedium: AppFont.titleMedium,
      titleSmall: AppFont.titleSmall,
      bodyLarge: AppFont.bodyLarge,
      bodyMedium: AppFont.bodyMedium,
      bodySmall: AppFont.bodySmall,
      labelLarge: AppFont.labelLarge,
      labelMedium: AppFont.labelMedium,
      labelSmall: AppFont.labelSmall,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A),
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.white,
    ),

    cardTheme: const CardThemeData(
      color: Color(0xFF1E293B),
      elevation: 0,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
  );
}
