import 'package:intl/intl.dart';

/// Centralized application constants, default values, and formatters.
class AppConstants {
  AppConstants._();

  // ── Date & Time Format Strings ───────────────────────────────────
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatShort = 'dd/MM';
  static const String timeFormat = 'HH:mm';
  static const String dateFormatIso = 'yyyy-MM-dd';
  static const String dateFormatFileTimestamp = 'yyyyMMdd_HHmmss';
  static const String dateFormatFull = 'dd/MM/yyyy HH:mm';
  static const String dateFormatWithSeconds = 'dd/MM/yyyy HH:mm:ss';

  // ── Date Formatters ────────────────────────────────────────────────
  static final DateFormat dateFormatter = DateFormat(dateFormatDisplay);
  static final DateFormat shortDateFormatter = DateFormat(dateFormatShort);
  static final DateFormat timeFormatter = DateFormat(timeFormat);
  static final DateFormat isoDateFormatter = DateFormat(dateFormatIso);

  /// Helper to format date as "dd/MM/yyyy"
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return dateFormatter.format(date);
  }

  /// Helper to format date as "dd/MM"
  static String formatDateShort(DateTime? date) {
    if (date == null) return '';
    return shortDateFormatter.format(date);
  }

  /// Helper to format time as "HH:mm"
  static String formatTime(DateTime? time) {
    if (time == null) return '';
    return timeFormatter.format(time);
  }

  /// Helper to format date as "yyyy-MM-dd"
  static String formatIsoDate(DateTime? date) {
    if (date == null) return '';
    return isoDateFormatter.format(date);
  }

  // ── Financial & Job Defaults ──────────────────────────────────────
  static const double defaultHourlyRate = 40.22;
  static const String defaultCurrencySymbol = '₪';
  static const double defaultPaidBreakMinutes = 0.0;
  static const double defaultUnpaidBreakMinutes = 30.0;

  // ── Layout & Responsive Breakpoints ─────────────────────────────
  static const double wideScreenWidth = 768.0;

  // ── Date Picker Limits ───────────────────────────────────────────
  static final DateTime minPickerDate = DateTime(2020);
  static final DateTime maxPickerDate = DateTime(2100);
  static final DateTime minBirthDate = DateTime(1900);
  static DateTime get defaultBirthDate =>
      DateTime.now().subtract(const Duration(days: 365 * 18));
}
