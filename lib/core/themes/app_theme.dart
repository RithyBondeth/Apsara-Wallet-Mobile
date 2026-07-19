import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font.dart';
import 'app_gradients.dart';

class AppTheme {
  /// Branded Material date picker: emerald header, gold "today" ring,
  /// soft rounded dialog — shared by light/dark with surface swaps.
  static DatePickerThemeData _datePickerTheme({
    required Color background,
    required Color onSurface,
    required Color muted,
  }) {
    return DatePickerThemeData(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
      headerHelpStyle: AppFont.labelMedium.copyWith(
        color: const Color(0xCCF3F1E7),
        letterSpacing: 0.4,
      ),
      headerHeadlineStyle: AppFont.headingSmall.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      weekdayStyle: AppFont.labelMedium.copyWith(
        color: muted,
        fontWeight: FontWeight.w700,
      ),
      dayStyle: AppFont.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      dayForegroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? Colors.white : onSurface,
      ),
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.transparent,
      ),
      dayOverlayColor: WidgetStatePropertyAll(
        AppColors.primary.withValues(alpha: 0.08),
      ),
      todayForegroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.primary,
      ),
      todayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.transparent,
      ),
      todayBorder: const BorderSide(color: AppGradients.goldCore, width: 1.4),
      yearStyle: AppFont.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      yearForegroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? Colors.white : onSurface,
      ),
      yearBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.transparent,
      ),
      dividerColor: Colors.transparent,
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: muted,
        textStyle: AppFont.labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppFont.labelLarge.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }

  /// Matching time picker (used by Add Transaction's Date & Time row).
  static TimePickerThemeData _timePickerTheme({
    required Color background,
    required Color onSurface,
    required Color field,
  }) {
    return TimePickerThemeData(
      backgroundColor: background,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      dialHandColor: AppColors.primary,
      dialBackgroundColor: field,
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      hourMinuteColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary.withValues(alpha: 0.12)
            : field,
      ),
      hourMinuteTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : onSurface,
      ),
      dayPeriodColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.transparent,
      ),
      dayPeriodTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : onSurface,
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColors.textMuted,
        textStyle: AppFont.labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppFont.labelLarge.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }

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

    datePickerTheme: _datePickerTheme(
      background: AppColors.surface,
      onSurface: AppColors.textPrimary,
      muted: AppColors.textMuted,
    ),
    timePickerTheme: _timePickerTheme(
      background: AppColors.surface,
      onSurface: AppColors.textPrimary,
      field: AppColors.surfaceVariant,
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

    datePickerTheme: _datePickerTheme(
      background: const Color(0xFF1E293B),
      onSurface: Colors.white,
      muted: const Color(0xFF94A3B8),
    ),
    timePickerTheme: _timePickerTheme(
      background: const Color(0xFF1E293B),
      onSurface: Colors.white,
      field: const Color(0xFF33415C),
    ),
  );
}
