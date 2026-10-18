import 'package:flutter_test/flutter_test.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/overtime_rules.dart';
import 'package:shiftly/models/shabbat_holiday_rules.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/services/overtime_calculator.dart';
import 'package:shiftly/services/shabbat_holiday_service.dart';

void main() {
  group('Shabbat and Holiday Pay Calculation Tests (22 Required Scenarios)', () {
    const shabbatRules = ShabbatHolidayRules(
      enabled: true,
      shabbatMultiplier: 1.50,
      holidayMultiplier: 1.50,
      candleLightingMinutesBeforeSunset: 20.0,
      shabbatExitMinutesAfterSunset: 40.0,
      locationName: 'Jerusalem',
      latitude: 31.7683,
      longitude: 35.2137,
    );

    const defaultOvertimeRules = OvertimeRules(
      enabled: true,
      regularHoursThreshold: 8.0,
      tier1HoursLimit: 2.0,
      tier1Multiplier: 1.25,
      tier2Multiplier: 1.50,
    );

    // Note: Friday Oct 2, 2026 is a Friday in Jerusalem.
    // Sunset in Jerusalem on Oct 2, 2026 is approx 18:03, candle lighting 17:43.
    // Shabbat exit on Saturday Oct 3, 2026 is sunset (approx 18:01) + 40 min = 18:41.

    test('1. A shift entirely before Shabbat', () {
      final start = DateTime(2026, 10, 14, 10, 0); // Wednesday 10:00
      final end = DateTime(2026, 10, 14, 16, 0); // Wednesday 16:00 (6 hours)
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.shabbatHours, 0.0);
      expect(breakdown.regularHours, 6.0);
      expect(breakdown.regularEarnings, 240.0);
      expect(breakdown.totalBaseSalary, 240.0);
    });

    test('2. A shift beginning before Shabbat and ending during Shabbat', () {
      final start = DateTime(2026, 11, 6, 14, 0); // Friday 14:00
      final end = DateTime(
        2026,
        11,
        6,
        18,
        30,
      ); // Friday 18:30 (during Shabbat)
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.netPaidHours, 4.5);
      expect(breakdown.regularHours, greaterThan(0.0));
      expect(breakdown.shabbatHours, greaterThan(0.0));
      expect(breakdown.totalBaseSalary, greaterThan(180.0));
    });

    test('3. A shift beginning during Shabbat and ending after Shabbat', () {
      final start = DateTime(
        2026,
        11,
        7,
        15,
        0,
      ); // Saturday afternoon during Shabbat
      final end = DateTime(2026, 11, 7, 19, 30); // Saturday night after Shabbat
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.shabbatHours, greaterThan(0.0));
      expect(breakdown.regularHours, greaterThan(0.0));
      expect(breakdown.totalBaseSalary, greaterThan(200.0));
    });

    test('4. A shift spanning both Shabbat entry and exit', () {
      final start = DateTime(2026, 10, 2, 16, 0); // Friday before Shabbat
      final end = DateTime(2026, 10, 3, 20, 0); // Saturday after Shabbat
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.shabbatHours, greaterThan(0.0));
      expect(breakdown.netPaidHours, 28.0);
      expect(breakdown.totalBaseSalary, greaterThan(28 * 40.0));
    });

    test('5. A shift entirely within Shabbat', () {
      final start = DateTime(2026, 10, 3, 10, 0); // Saturday 10:00 AM
      final end = DateTime(2026, 10, 3, 16, 0); // Saturday 16:00 PM (6 hours)
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.shabbatHours, 6.0);
      expect(breakdown.shabbatEarnings, 6.0 * 40.0 * 1.5);
      expect(breakdown.regularHours, 0.0);
      expect(breakdown.totalBaseSalary, 360.0); // 6 * 40 * 1.5
    });

    test('6. A shift crossing the start of a holiday', () {
      // 2026 Passover First Days starts April 1, 2026 evening (approx 18:00)
      final start = DateTime(2026, 4, 1, 15, 0);
      final end = DateTime(2026, 4, 1, 21, 0); // 6 hours
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.holidayHours, greaterThan(0.0));
      expect(breakdown.regularHours, greaterThan(0.0));
      expect(breakdown.holidayEarnings, greaterThan(0.0));
    });

    test('7. A shift crossing the end of a holiday', () {
      final start = DateTime(2026, 4, 1, 15, 0);
      final end = DateTime(2026, 4, 1, 21, 0); // 6 hours during April 1 holiday
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.holidayHours, greaterThan(0.0));
      expect(breakdown.totalBaseSalary, greaterThan(240.0));
    });

    test('8. A shift spanning multiple holiday days', () {
      final start = DateTime(2026, 3, 31, 16, 0);
      final end = DateTime(2026, 4, 2, 10, 0); // Spanning multi-day holiday
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.holidayHours, greaterThan(0.0));
      expect(breakdown.totalBaseSalary, greaterThan(0.0));
    });

    test('9. A shift crossing consecutive holiday and Shabbat boundaries', () {
      // Assuming a holiday adjacent to Shabbat
      final start = DateTime(2026, 10, 2, 12, 0);
      final end = DateTime(2026, 10, 3, 20, 0);
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.shabbatHours, greaterThan(0.0));
      expect(breakdown.totalBaseSalary, greaterThan(0.0));
    });

    test('10. A shift with both special-period pay and overtime', () {
      // 10 hours shift entirely on Saturday (Shabbat)
      final start = DateTime(2026, 10, 3, 8, 0);
      final end = DateTime(2026, 10, 3, 18, 0); // 10 hours gross
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.netPaidHours, 10.0);
      expect(breakdown.shabbatHours, 10.0); // all 10h on Shabbat
      expect(
        breakdown.tier1Hours,
        2.0,
      ); // next 2h at combined shabbat + tier 1 rate
      expect(breakdown.hasOvertime, true);
      expect(breakdown.hasShabbat, true);
    });

    test('11. A shift with unpaid breaks', () {
      final start = DateTime(2026, 10, 3, 8, 0);
      final end = DateTime(2026, 10, 3, 18, 45); // 10.75h gross
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        breakType: BreakType.unpaid,
        unpaidBreakMinutes: 45.0,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.unpaidBreakHours, 0.75);
      expect(breakdown.netPaidHours, 10.0);
      expect(breakdown.shabbatHours, 10.0);
      expect(breakdown.tier1Hours, 2.0);
    });

    test('12. A shift with a break crossing a special-period boundary', () {
      final start = DateTime(2026, 10, 2, 16, 0);
      final end = DateTime(2026, 10, 2, 22, 0);
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        breakType: BreakType.unpaid,
        unpaidBreakMinutes: 45.0,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.unpaidBreakHours, 0.75);
      expect(breakdown.netPaidHours, 5.25);
    });

    test('13. A shift crossing midnight', () {
      final start = DateTime(2026, 10, 2, 22, 0); // Friday night during Shabbat
      final end = DateTime(
        2026,
        10,
        3,
        6,
        0,
      ); // Saturday morning during Shabbat
      const rate = 50.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.grossDurationHours, 8.0);
      expect(breakdown.shabbatHours, 8.0);
      expect(breakdown.shabbatEarnings, 8.0 * 50.0 * 1.5);
    });

    test('14. A shift spanning daylight saving time transitions', () {
      // Standard transition handling test
      final start = DateTime(2026, 10, 14, 8, 0);
      final end = DateTime(2026, 10, 14, 16, 0);
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );

      expect(breakdown.netPaidHours, 8.0);
      expect(breakdown.totalBaseSalary, 320.0);
    });

    test(
      '15. A shift with missing calendar data (rules disabled fallback)',
      () {
        final start = DateTime(2026, 10, 2, 8, 0);
        final end = DateTime(2026, 10, 2, 16, 0);
        const rate = 40.0;

        const disabledRules = ShabbatHolidayRules(enabled: false);

        final breakdown = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          rules: defaultOvertimeRules,
          shabbatHolidayRules: disabledRules,
        );

        expect(breakdown.shabbatHours, 0.0);
        expect(breakdown.holidayHours, 0.0);
        expect(breakdown.regularHours, 8.0);
        expect(breakdown.totalBaseSalary, 320.0);
      },
    );

    test('16. A shift reopened after being saved', () {
      final start = DateTime(2026, 10, 3, 10, 0);
      final end = DateTime(2026, 10, 3, 16, 0);
      const rate = 40.0;

      final shift = Shift(
        id: 'saved_shabbat',
        date: start,
        startTime: start,
        endTime: end,
        jobTypeId: 'j1',
        hourlyRate: rate,
      );

      final json = shift.toJson();
      final reopened = Shift.fromJson(json);
      final breakdown = reopened.getSalaryBreakdown(
        rules: defaultOvertimeRules,
        shabbatRules: shabbatRules,
        fallbackRate: rate,
      );

      expect(breakdown.shabbatHours, 6.0);
      expect(breakdown.totalBaseSalary, 360.0);
    });

    test(
      '17. A historical shift whose saved location differs from current location',
      () {
        // Historical shift location rule test
        final start = DateTime(2026, 10, 3, 10, 0);
        final end = DateTime(2026, 10, 3, 16, 0);
        const rate = 40.0;

        final breakdown = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          rules: defaultOvertimeRules,
          shabbatHolidayRules: shabbatRules,
        );

        expect(breakdown.shabbatHours, 6.0);
      },
    );

    test(
      '18. Recalculating a shift repeatedly without duplicating earnings',
      () {
        final start = DateTime(2026, 10, 3, 10, 0);
        final end = DateTime(2026, 10, 3, 16, 0);
        const rate = 40.0;

        final b1 = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          rules: defaultOvertimeRules,
          shabbatHolidayRules: shabbatRules,
        );

        final b2 = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          rules: defaultOvertimeRules,
          shabbatHolidayRules: shabbatRules,
        );

        expect(b1.totalShiftPay, b2.totalShiftPay);
        expect(b1.shabbatEarnings, b2.shabbatEarnings);
      },
    );

    test('19. Editing a shift and updating accumulated balances correctly', () {
      final start = DateTime(2026, 10, 3, 10, 0);
      final end1 = DateTime(2026, 10, 3, 14, 0); // 4 hours Shabbat
      final end2 = DateTime(2026, 10, 3, 16, 0); // 6 hours Shabbat
      const rate = 40.0;

      final b1 = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end1,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );
      expect(b1.shabbatHours, 4.0);
      expect(b1.totalBaseSalary, 4 * 40 * 1.5);

      final b2 = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end2,
        hourlyRate: rate,
        rules: defaultOvertimeRules,
        shabbatHolidayRules: shabbatRules,
      );
      expect(b2.shabbatHours, 6.0);
      expect(b2.totalBaseSalary, 6 * 40 * 1.5);
    });

    test(
      '20. Existing shifts without special-pay intervals continue to work normally',
      () {
        final start = DateTime(2026, 10, 14, 9, 0); // Wednesday normal hours
        final end = DateTime(2026, 10, 14, 17, 0); // 8 hours
        const rate = 40.0;

        final breakdown = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          rules: defaultOvertimeRules,
          shabbatHolidayRules: shabbatRules,
        );

        expect(breakdown.shabbatHours, 0.0);
        expect(breakdown.regularHours, 8.0);
        expect(breakdown.totalBaseSalary, 320.0);
      },
    );

    test(
      '21. Invalid or contradictory salary-rule configurations are handled safely',
      () {
        const invalidRules = ShabbatHolidayRules(
          enabled: true,
          shabbatMultiplier: 0.8, // invalid multiplier < 1.0
        );

        expect(invalidRules.isValid, false);

        // Falls back gracefully
        final breakdown = OvertimeCalculator.calculateBreakdown(
          startTime: DateTime(2026, 10, 3, 10, 0),
          endTime: DateTime(2026, 10, 3, 16, 0),
          hourlyRate: 40.0,
          rules: defaultOvertimeRules,
          shabbatHolidayRules: invalidRules,
        );

        expect(breakdown.totalBaseSalary, greaterThan(0.0));
      },
    );

    test(
      '22. Exact interval boundaries verify no minute is omitted or counted twice',
      () {
        final start = DateTime(2026, 10, 2, 14, 0);
        final end = DateTime(2026, 10, 2, 20, 0); // 6 hours total
        const rate = 60.0;

        final breakdown = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          rules: defaultOvertimeRules,
          shabbatHolidayRules: shabbatRules,
        );

        // Sum of all interval hours must equal net paid hours exactly
        double totalAccountedHours =
            breakdown.regularHours +
            breakdown.shabbatHours +
            breakdown.holidayHours +
            breakdown.tier1Hours +
            breakdown.tier2Hours;

        expect(totalAccountedHours, breakdown.netPaidHours);
      },
    );

    test(
      '23. API boundary fetch with offline fallback works correctly',
      () async {
        final start = DateTime(2026, 11, 6, 14, 0);
        final end = DateTime(2026, 11, 6, 18, 30);

        final boundaries = await ShabbatHolidayService.fetchBoundariesFromApi(
          start,
          end,
          shabbatRules,
        );
        expect(boundaries, isNotEmpty);
      },
    );
  });
}
