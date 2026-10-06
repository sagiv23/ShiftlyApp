import 'package:flutter/material.dart' as mat;
import '../theme/app_theme.dart';
import 'app_constants.dart';

/// Unified theme and helper methods for date pickers across Shiftly.
class AppDatePicker {
  AppDatePicker._();

  /// Opens a unified single date picker dialog.
  static Future<DateTime?> showSingleDatePicker({
    required mat.BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    mat.DatePickerMode initialDatePickerMode = mat.DatePickerMode.day,
    String? helpText,
  }) async {
    final theme = mat.Theme.of(context);
    final isDark = theme.brightness == mat.Brightness.dark;

    return await mat.showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? AppConstants.minPickerDate,
      lastDate: lastDate ?? AppConstants.maxPickerDate,
      initialDatePickerMode: initialDatePickerMode,
      helpText: helpText,
      builder: (context, child) {
        return mat.Theme(
          data: theme.copyWith(
            datePickerTheme: mat.DatePickerThemeData(
              backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              headerBackgroundColor: AppTheme.primaryDark,
              headerForegroundColor: mat.Colors.white,
              surfaceTintColor: mat.Colors.transparent,
              shape: mat.RoundedRectangleBorder(
                borderRadius: mat.BorderRadius.circular(AppTheme.radiusLg),
              ),
              dayStyle: const mat.TextStyle(fontWeight: mat.FontWeight.w500),
              todayBorder: const mat.BorderSide(color: AppTheme.primary, width: 1.5),
              todayForegroundColor: mat.WidgetStateProperty.all(AppTheme.primaryDark),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// Opens a unified birth date picker dialog starting in Year selection mode.
  static Future<DateTime?> showBirthDatePicker({
    required mat.BuildContext context,
    DateTime? initialDate,
  }) async {
    return await showSingleDatePicker(
      context: context,
      initialDate: initialDate ?? AppConstants.defaultBirthDate,
      firstDate: AppConstants.minBirthDate,
      lastDate: DateTime.now(),
      initialDatePickerMode: mat.DatePickerMode.year,
    );
  }

  /// Opens a unified date range picker dialog.
  static Future<mat.DateTimeRange?> showDateRangePicker({
    required mat.BuildContext context,
    mat.DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
  }) async {
    final theme = mat.Theme.of(context);
    final isDark = theme.brightness == mat.Brightness.dark;

    return await mat.showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: firstDate ?? AppConstants.minPickerDate,
      lastDate: lastDate ?? AppConstants.maxPickerDate,
      helpText: helpText,
      builder: (context, child) {
        return mat.Theme(
          data: theme.copyWith(
            datePickerTheme: mat.DatePickerThemeData(
              backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              headerBackgroundColor: AppTheme.primaryDark,
              headerForegroundColor: mat.Colors.white,
              surfaceTintColor: mat.Colors.transparent,
              shape: mat.RoundedRectangleBorder(
                borderRadius: mat.BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
