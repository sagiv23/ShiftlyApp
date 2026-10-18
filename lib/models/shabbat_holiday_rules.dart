import 'package:shiftly/utils/number_utils.dart';

class ShabbatHolidayRules {
  final bool enabled;
  final double shabbatMultiplier;
  final double holidayMultiplier;
  final double candleLightingMinutesBeforeSunset;
  final double shabbatExitMinutesAfterSunset;
  final String locationName;
  final double latitude;
  final double longitude;
  final bool includeCholHaMoed;
  final bool diaspora;
  final String
  combinationPolicy; // 'specialDayMultiplierThenOvertime', 'maxOfSpecialAndOvertime', 'addMultipliers'

  const ShabbatHolidayRules({
    this.enabled = false,
    this.shabbatMultiplier = 1.50,
    this.holidayMultiplier = 1.50,
    this.candleLightingMinutesBeforeSunset = 20.0,
    this.shabbatExitMinutesAfterSunset = 40.0,
    this.locationName = 'Jerusalem',
    this.latitude = 31.7683,
    this.longitude = 35.2137,
    this.includeCholHaMoed = false,
    this.diaspora = false,
    this.combinationPolicy = 'specialDayMultiplierThenOvertime',
  });

  String? validate() {
    if (shabbatMultiplier < 1.0) {
      return 'Shabbat multiplier must be at least 1.0 (100%)';
    }
    if (holidayMultiplier < 1.0) {
      return 'Holiday multiplier must be at least 1.0 (100%)';
    }
    if (candleLightingMinutesBeforeSunset < 0) {
      return 'Candle lighting offset cannot be negative';
    }
    if (shabbatExitMinutesAfterSunset < 0) {
      return 'Shabbat exit offset cannot be negative';
    }
    return null;
  }

  bool get isValid => validate() == null;

  ShabbatHolidayRules copyWith({
    bool? enabled,
    double? shabbatMultiplier,
    double? holidayMultiplier,
    double? candleLightingMinutesBeforeSunset,
    double? shabbatExitMinutesAfterSunset,
    String? locationName,
    double? latitude,
    double? longitude,
    bool? includeCholHaMoed,
    bool? diaspora,
    String? combinationPolicy,
  }) {
    return ShabbatHolidayRules(
      enabled: enabled ?? this.enabled,
      shabbatMultiplier: shabbatMultiplier ?? this.shabbatMultiplier,
      holidayMultiplier: holidayMultiplier ?? this.holidayMultiplier,
      candleLightingMinutesBeforeSunset:
          candleLightingMinutesBeforeSunset ??
          this.candleLightingMinutesBeforeSunset,
      shabbatExitMinutesAfterSunset:
          shabbatExitMinutesAfterSunset ?? this.shabbatExitMinutesAfterSunset,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      includeCholHaMoed: includeCholHaMoed ?? this.includeCholHaMoed,
      diaspora: diaspora ?? this.diaspora,
      combinationPolicy: combinationPolicy ?? this.combinationPolicy,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'shabbatMultiplier': shabbatMultiplier,
    'holidayMultiplier': holidayMultiplier,
    'candleLightingMinutesBeforeSunset': candleLightingMinutesBeforeSunset,
    'shabbatExitMinutesAfterSunset': shabbatExitMinutesAfterSunset,
    'locationName': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'includeCholHaMoed': includeCholHaMoed,
    'diaspora': diaspora,
    'combinationPolicy': combinationPolicy,
  };

  factory ShabbatHolidayRules.fromJson(Map<String, dynamic> json) =>
      ShabbatHolidayRules(
        enabled: NumberUtils.parseBool(json['enabled'], false),
        shabbatMultiplier: NumberUtils.parseDouble(
          json['shabbatMultiplier'] ?? json['shabbat_multiplier'],
          1.50,
        ),
        holidayMultiplier: NumberUtils.parseDouble(
          json['holidayMultiplier'] ?? json['holiday_multiplier'],
          1.50,
        ),
        candleLightingMinutesBeforeSunset: NumberUtils.parseDouble(
          json['candleLightingMinutesBeforeSunset'] ??
              json['candle_lighting_minutes_before_sunset'],
          20.0,
        ),
        shabbatExitMinutesAfterSunset: NumberUtils.parseDouble(
          json['shabbatExitMinutesAfterSunset'] ??
              json['shabbat_exit_minutes_after_sunset'],
          40.0,
        ),
        locationName:
            json['locationName'] ?? json['location_name'] ?? 'Jerusalem',
        latitude: NumberUtils.parseDouble(json['latitude'], 31.7683),
        longitude: NumberUtils.parseDouble(json['longitude'], 35.2137),
        includeCholHaMoed: NumberUtils.parseBool(
          json['includeCholHaMoed'] ?? json['include_chol_ha_moed'],
          false,
        ),
        diaspora: NumberUtils.parseBool(json['diaspora'], false),
        combinationPolicy:
            json['combinationPolicy'] ??
            json['combination_policy'] ??
            'specialDayMultiplierThenOvertime',
      );
}
