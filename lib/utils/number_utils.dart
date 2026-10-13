class NumberUtils {
  /// Safely parses a dynamic value (num, String, int, double) into a double.
  /// Returns [defaultValue] if null or parsing fails.
  static double parseDouble(dynamic val, [double defaultValue = 0.0]) {
    if (val == null) return defaultValue;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  /// Safely parses a dynamic value into a double, returning null if null or parsing fails.
  static double? parseNullableDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  /// Safely parses a dynamic value into a boolean.
  static bool parseBool(dynamic val, [bool defaultValue = false]) {
    if (val == null) return defaultValue;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final s = val.trim().toLowerCase();
      return s == 'true' || s == 't' || s == '1' || s == 'y' || s == 'yes';
    }
    return defaultValue;
  }
}
