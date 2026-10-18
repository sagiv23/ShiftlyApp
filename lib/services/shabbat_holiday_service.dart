import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shiftly/models/shabbat_holiday_rules.dart';

class SpecialPeriodBoundary {
  final DateTime start;
  final DateTime end;
  final String type; // 'shabbat' or 'holiday'
  final String name; // e.g. 'Shabbat', 'Rosh Hashanah', 'Passover', etc.
  final double multiplier;

  const SpecialPeriodBoundary({
    required this.start,
    required this.end,
    required this.type,
    required this.name,
    required this.multiplier,
  });

  bool contains(DateTime time) {
    return (!time.isBefore(start)) && time.isBefore(end);
  }

  @override
  String toString() => 'SpecialPeriodBoundary($name, $start to $end)';
}

class ShabbatHolidayService {
  static final Map<String, List<SpecialPeriodBoundary>> _cache = {};

  /// Fetches exact Shabbat and holiday boundaries from Hebcal REST API and merges with local fallback.
  static Future<List<SpecialPeriodBoundary>> fetchBoundariesFromApi(
    DateTime start,
    DateTime end,
    ShabbatHolidayRules rules,
  ) async {
    if (!rules.enabled) return [];

    String cacheKey =
        'api_${rules.latitude}_${rules.longitude}_${rules.candleLightingMinutesBeforeSunset}_${rules.shabbatExitMinutesAfterSunset}_${start.year}_${start.month}_${start.day}_${end.year}_${end.month}_${end.day}_${rules.diaspora}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    List<SpecialPeriodBoundary> boundaries = [];

    try {
      final startStr =
          "${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
      final endStr =
          "${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

      final url = Uri.parse(
        'https://www.hebcal.com/hebcal?v=1&cfg=json&maj=on&min=off&mod=off&nx=off&start=$startStr&end=$endStr&geo=pos&latitude=${rules.latitude}&longitude=${rules.longitude}&b=${rules.candleLightingMinutesBeforeSunset.round()}&m=${rules.shabbatExitMinutesAfterSunset.round()}',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List?;

        if (items != null) {
          DateTime? candleTime;
          String? currentHolidayName;

          for (var item in items) {
            final category = item['category']?.toString();
            final title = item['title']?.toString() ?? '';
            final dateRaw = item['date']?.toString();

            if (category == 'candles' && dateRaw != null) {
              candleTime = DateTime.tryParse(dateRaw)?.toLocal();
            } else if (category == 'havdalah' &&
                dateRaw != null &&
                candleTime != null) {
              final havdalahTime = DateTime.tryParse(dateRaw)?.toLocal();
              if (havdalahTime != null) {
                final name = currentHolidayName ?? 'שבת קודש';
                final isHoliday = currentHolidayName != null;

                boundaries.add(
                  SpecialPeriodBoundary(
                    start: candleTime,
                    end: havdalahTime,
                    type: isHoliday ? 'holiday' : 'shabbat',
                    name: name,
                    multiplier: isHoliday
                        ? rules.holidayMultiplier
                        : rules.shabbatMultiplier,
                  ),
                );
                candleTime = null;
                currentHolidayName = null;
              }
            } else if (category == 'holiday' &&
                (item['yomtov'] == true ||
                    title.contains('Pesach') ||
                    title.contains('Shavuot') ||
                    title.contains('Rosh Hashanah') ||
                    title.contains('Yom Kippur') ||
                    title.contains('Sukkot') ||
                    title.contains('Simchat Torah') ||
                    title.contains('Shemini Atzeret') ||
                    title.contains('ראש השנה') ||
                    title.contains('יום כיפור') ||
                    title.contains('סוכות') ||
                    title.contains('פסח') ||
                    title.contains('שבועות'))) {
              currentHolidayName = title;
            }
          }
        }
      }
    } catch (_) {}

    // Always merge with local fallback boundaries to guarantee 100% coverage
    final localBoundaries = getBoundariesForRange(start, end, rules);
    for (var lb in localBoundaries) {
      if (!boundaries.any((b) => b.start.isAtSameMomentAs(lb.start))) {
        boundaries.add(lb);
      }
    }

    _cache[cacheKey] = boundaries;
    return boundaries;
  }

  /// Synchronous boundary retrieval (uses local cache or astronomical fallback).
  static List<SpecialPeriodBoundary> getBoundariesForRange(
    DateTime start,
    DateTime end,
    ShabbatHolidayRules rules,
  ) {
    if (!rules.enabled) return [];

    String cacheKey =
        '${rules.latitude}_${rules.longitude}_${rules.candleLightingMinutesBeforeSunset}_${rules.shabbatExitMinutesAfterSunset}_${start.year}_${start.month}_${start.day}_${end.year}_${end.month}_${end.day}_${rules.diaspora}_${rules.includeCholHaMoed}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    List<SpecialPeriodBoundary> boundaries = [];

    DateTime cursor = DateTime(
      start.year,
      start.month,
      start.day,
    ).subtract(const Duration(days: 2));
    DateTime limit = DateTime(
      end.year,
      end.month,
      end.day,
    ).add(const Duration(days: 2));

    Set<String> processedFridays = {};

    while (cursor.isBefore(limit) || cursor.isAtSameMomentAs(limit)) {
      DateTime d = DateTime(cursor.year, cursor.month, cursor.day);
      int diff = DateTime.friday - d.weekday;
      d = d.add(Duration(days: diff));

      String key = '${d.year}-${d.month}-${d.day}';
      if (!processedFridays.contains(key)) {
        processedFridays.add(key);
        boundaries.add(getShabbatBoundary(d, rules));
      }

      final holiday = _getHolidayForDate(cursor, rules);
      if (holiday != null) {
        if (!boundaries.any(
          (b) => b.type == 'holiday' && b.start.isAtSameMomentAs(holiday.start),
        )) {
          boundaries.add(holiday);
        }
      }

      cursor = cursor.add(const Duration(days: 1));
    }

    _cache[cacheKey] = boundaries;
    return boundaries;
  }

  /// Gets Shabbat boundaries for the weekend surrounding [date].
  static SpecialPeriodBoundary getShabbatBoundary(
    DateTime date,
    ShabbatHolidayRules rules,
  ) {
    DateTime d = DateTime(date.year, date.month, date.day);
    int diff = DateTime.friday - d.weekday;
    d = d.add(Duration(days: diff));

    DateTime fridaySunset = calculateSunset(d, rules.latitude, rules.longitude);
    DateTime shabbatStart = fridaySunset.subtract(
      Duration(minutes: rules.candleLightingMinutesBeforeSunset.round()),
    );

    DateTime saturdayDate = d.add(const Duration(days: 1));
    DateTime saturdaySunset = calculateSunset(
      saturdayDate,
      rules.latitude,
      rules.longitude,
    );
    DateTime shabbatEnd = saturdaySunset.add(
      Duration(minutes: rules.shabbatExitMinutesAfterSunset.round()),
    );

    return SpecialPeriodBoundary(
      start: shabbatStart,
      end: shabbatEnd,
      type: 'shabbat',
      name: 'שבת קודש',
      multiplier: rules.shabbatMultiplier,
    );
  }

  /// Computes local sunset time for a given date and coordinates using NOAA solar formula.
  static DateTime calculateSunset(DateTime date, double lat, double lon) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    int doy = normalizedDate.difference(DateTime(date.year, 1, 1)).inDays + 1;

    double gamma = 2 * pi / 365 * (doy - 1);
    double eqtime =
        229.18 *
        (0.000075 +
            0.001868 * cos(gamma) -
            0.032077 * sin(gamma) -
            0.014615 * cos(2 * gamma) -
            0.040849 * sin(2 * gamma));
    double decl =
        0.006918 -
        0.399912 * cos(gamma) +
        0.070257 * sin(gamma) -
        0.006758 * cos(2 * gamma) +
        0.000907 * sin(2 * gamma) -
        0.002697 * cos(3 * gamma) +
        0.00148 * sin(3 * gamma);

    double zenith = 90.833 * pi / 180.0;
    double latRad = lat * pi / 180.0;
    double cosHourAngle =
        (cos(zenith) - sin(latRad) * sin(decl)) / (cos(latRad) * cos(decl));
    cosHourAngle = cosHourAngle.clamp(-1.0, 1.0);
    double hourAngle = acos(cosHourAngle);

    double solarNoon = 720 - 4 * lon - eqtime; // minutes UTC
    double sunsetMinutesUtc =
        solarNoon + hourAngle * 180 / pi * 4; // minutes UTC

    int tzOffsetMinutes = date.timeZoneOffset.inMinutes;
    double localSunsetMinutes = sunsetMinutesUtc + tzOffsetMinutes;

    int hour = (localSunsetMinutes / 60).floor() % 24;
    int minute = (localSunsetMinutes % 60).round();

    if (hour < 16 || hour > 21) {
      hour = 18;
      minute = 30;
    }

    return DateTime(
      normalizedDate.year,
      normalizedDate.month,
      normalizedDate.day,
      hour,
      minute,
    );
  }

  static SpecialPeriodBoundary? _getHolidayForDate(
    DateTime date,
    ShabbatHolidayRules rules,
  ) {
    DateTime d = DateTime(date.year, date.month, date.day);

    List<Map<String, dynamic>> knownHolidays = [
      // 2025
      {
        'start': DateTime(2025, 4, 12, 18, 0),
        'end': DateTime(2025, 4, 13, 20, 0),
        'name': 'פסח (יום ראשון)',
      },
      {
        'start': DateTime(2025, 4, 18, 18, 0),
        'end': DateTime(2025, 4, 19, 20, 0),
        'name': 'פסח (שביעי של פסח)',
      },
      {
        'start': DateTime(2025, 6, 1, 18, 0),
        'end': DateTime(2025, 6, 2, 20, 0),
        'name': 'שבועות',
      },
      {
        'start': DateTime(2025, 9, 22, 18, 0),
        'end': DateTime(2025, 9, 24, 20, 0),
        'name': 'ראש השנה',
      },
      {
        'start': DateTime(2025, 10, 1, 18, 0),
        'end': DateTime(2025, 10, 2, 20, 0),
        'name': 'יום כיפור',
      },
      {
        'start': DateTime(2025, 10, 6, 18, 0),
        'end': DateTime(2025, 10, 7, 20, 0),
        'name': 'סוכות (יום ראשון)',
      },
      {
        'start': DateTime(2025, 10, 13, 18, 0),
        'end': DateTime(2025, 10, 14, 20, 0),
        'name': 'שמיני עצרת ושמחת תורה',
      },

      // 2026
      {
        'start': DateTime(2026, 4, 1, 18, 0),
        'end': DateTime(2026, 4, 2, 20, 0),
        'name': 'פסח (יום ראשון)',
      },
      {
        'start': DateTime(2026, 4, 7, 18, 0),
        'end': DateTime(2026, 4, 8, 20, 0),
        'name': 'פסח (שביעי של פסח)',
      },
      {
        'start': DateTime(2026, 5, 21, 18, 0),
        'end': DateTime(2026, 5, 22, 20, 0),
        'name': 'שבועות',
      },
      {
        'start': DateTime(2026, 9, 11, 18, 0),
        'end': DateTime(2026, 9, 13, 20, 0),
        'name': 'ראש השנה',
      },
      {
        'start': DateTime(2026, 9, 20, 18, 0),
        'end': DateTime(2026, 9, 21, 20, 0),
        'name': 'יום כיפור',
      },
      {
        'start': DateTime(2026, 9, 25, 18, 0),
        'end': DateTime(2026, 9, 26, 20, 0),
        'name': 'סוכות (יום ראשון)',
      },
      {
        'start': DateTime(2026, 10, 2, 18, 0),
        'end': DateTime(2026, 10, 3, 20, 0),
        'name': 'שמיני עצרת ושמחת תורה',
      },

      // 2027
      {
        'start': DateTime(2027, 4, 21, 18, 0),
        'end': DateTime(2027, 4, 22, 20, 0),
        'name': 'פסח (יום ראשון)',
      },
      {
        'start': DateTime(2027, 4, 27, 18, 0),
        'end': DateTime(2027, 4, 28, 20, 0),
        'name': 'פסח (שביעי של פסח)',
      },
      {
        'start': DateTime(2027, 6, 10, 18, 0),
        'end': DateTime(2027, 6, 11, 20, 0),
        'name': 'שבועות',
      },
      {
        'start': DateTime(2027, 10, 1, 18, 0),
        'end': DateTime(2027, 10, 3, 20, 0),
        'name': 'ראש השנה',
      },
      {
        'start': DateTime(2027, 10, 10, 18, 0),
        'end': DateTime(2027, 10, 11, 20, 0),
        'name': 'יום כיפור',
      },
      {
        'start': DateTime(2027, 10, 15, 18, 0),
        'end': DateTime(2027, 10, 16, 20, 0),
        'name': 'סוכות (יום ראשון)',
      },
      {
        'start': DateTime(2027, 10, 22, 18, 0),
        'end': DateTime(2027, 10, 23, 20, 0),
        'name': 'שמיני עצרת ושמחת תורה',
      },
    ];

    if (rules.includeCholHaMoed) {
      knownHolidays.addAll([
        {
          'start': DateTime(2025, 4, 13, 20, 0),
          'end': DateTime(2025, 4, 18, 18, 0),
          'name': 'חול המועד פסח',
        },
        {
          'start': DateTime(2025, 10, 7, 20, 0),
          'end': DateTime(2025, 10, 13, 18, 0),
          'name': 'חול המועד סוכות',
        },
        {
          'start': DateTime(2026, 4, 2, 20, 0),
          'end': DateTime(2026, 4, 7, 18, 0),
          'name': 'חול המועד פסח',
        },
        {
          'start': DateTime(2026, 9, 26, 20, 0),
          'end': DateTime(2026, 10, 2, 18, 0),
          'name': 'חול המועד סוכות',
        },
        {
          'start': DateTime(2027, 4, 22, 20, 0),
          'end': DateTime(2027, 4, 27, 18, 0),
          'name': 'חול המועד פסח',
        },
        {
          'start': DateTime(2027, 10, 16, 20, 0),
          'end': DateTime(2027, 10, 22, 18, 0),
          'name': 'חול המועד סוכות',
        },
      ]);
    }

    for (var h in knownHolidays) {
      DateTime hStart = h['start'];
      DateTime hEnd = h['end'];
      if (!d.isBefore(DateTime(hStart.year, hStart.month, hStart.day)) &&
          !d.isAfter(DateTime(hEnd.year, hEnd.month, hEnd.day))) {
        return SpecialPeriodBoundary(
          start: hStart,
          end: hEnd,
          type: 'holiday',
          name: h['name'],
          multiplier: rules.holidayMultiplier,
        );
      }
    }

    return null;
  }
}
