import 'package:flutter_test/flutter_test.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_wage_segment.dart';
import 'package:shiftly/models/wage_entry.dart';
import 'package:shiftly/services/shift_parser.dart';

void main() {
  group('Shift Model Logic', () {
    test('calculate duration correctly for normal shift', () {
      final start = DateTime(2026, 6, 24, 9, 0);
      final end = DateTime(2026, 6, 24, 17, 0);
      final shift = Shift(
        id: '1',
        date: start,
        startTime: start,
        endTime: end,
        jobTypeId: 'j1',
      );

      expect(shift.durationHours, 8.0);
      expect(shift.netHours, 8.0);
    });

    test('calculate duration correctly for overnight shift', () {
      final start = DateTime(2026, 6, 24, 22, 0);
      final end = DateTime(2026, 6, 25, 6, 0);
      final shift = Shift(
        id: '1',
        date: start,
        startTime: start,
        endTime: end,
        jobTypeId: 'j1',
      );

      expect(shift.durationHours, 8.0);
    });

    test('deduct break correctly', () {
      final start = DateTime(2026, 6, 24, 9, 0);
      final end = DateTime(2026, 6, 24, 19, 0);
      final shift = Shift(
        id: '1',
        date: start,
        startTime: start,
        endTime: end,
        jobTypeId: 'j1',
        breakType: BreakType.unpaid,
      );

      expect(shift.durationHours, 10.0);
      expect(shift.netHours, 9.25);
    });

    test('snapshotted hourlyRate is preferred over fallback', () {
      final start = DateTime(2026, 9, 30, 9, 0);
      final end = DateTime(2026, 9, 30, 17, 0);
      final shift = Shift(
        id: '1',
        date: start,
        startTime: start,
        endTime: end,
        jobTypeId: 'j1',
        hourlyRate: 40.0,
      );

      // Even if "current" job rate is 45, snapshotted rate wins
      expect(shift.calculateTotalPay(45.0), 8 * 40.0);
    });
  });

  group('JobType wage history', () {
    test('getRateForDate returns rate effective on that date', () {
      final job = JobType(
        id: '1',
        name: 'מזנון',
        hourlyRate: 45.0,
        wageHistory: [
          WageEntry(startDate: DateTime(2020, 1, 1), hourlyRate: 40.0),
          WageEntry(startDate: DateTime(2026, 10, 1), hourlyRate: 45.0),
        ],
      );

      expect(job.getRateForDate(DateTime(2026, 9, 30)), 40.0);
      expect(job.getRateForDate(DateTime(2026, 10, 1)), 45.0);
      expect(job.getRateForDate(DateTime(2026, 11, 15)), 45.0);
    });

    test('raise does not change pay for snapshotted past shift', () {
      final job = JobType(
        id: '1',
        name: 'מזנון',
        hourlyRate: 45.0,
        wageHistory: [
          WageEntry(startDate: DateTime(2020, 1, 1), hourlyRate: 40.0),
          WageEntry(startDate: DateTime(2026, 10, 1), hourlyRate: 45.0),
        ],
      );

      final septShift = Shift(
        id: 's1',
        date: DateTime(2026, 9, 30),
        startTime: DateTime(2026, 9, 30, 9),
        endTime: DateTime(2026, 9, 30, 17),
        jobTypeId: job.id,
        hourlyRate: job.getRateForDate(DateTime(2026, 9, 30)),
      );

      // Viewing in November still uses snapshotted 40
      expect(septShift.hourlyRate, 40.0);
      expect(septShift.calculateTotalPay(job.hourlyRate), 8 * 40.0);
    });

    test('syncCurrentRate uses today effective wage', () {
      final job = JobType(
        id: '1',
        name: 'מזנון',
        hourlyRate: 40.0,
        wageHistory: [
          WageEntry(startDate: DateTime(2020, 1, 1), hourlyRate: 40.0),
          WageEntry(
            startDate: DateTime.now().add(const Duration(days: 30)),
            hourlyRate: 50.0,
          ),
        ],
      );

      job.syncCurrentRate();
      expect(job.hourlyRate, 40.0);
    });

    test('reverting a raise updates rate lookup for that date', () {
      final job = JobType(
        id: '1',
        name: 'מזנון',
        hourlyRate: 45.0,
        wageHistory: [
          WageEntry(startDate: DateTime(2020, 1, 1), hourlyRate: 40.0),
          WageEntry(startDate: DateTime(2026, 10, 1), hourlyRate: 45.0),
        ],
      );

      expect(job.getRateForDate(DateTime(2026, 10, 5)), 45.0);

      // Revert: replace the Oct 1 entry with the original rate
      job.wageHistory!.removeWhere(
        (e) =>
            e.startDate.year == 2026 &&
            e.startDate.month == 10 &&
            e.startDate.day == 1,
      );
      job.wageHistory!.add(
        WageEntry(startDate: DateTime(2026, 10, 1), hourlyRate: 40.0),
      );
      job.syncCurrentRate();

      expect(job.getRateForDate(DateTime(2026, 10, 5)), 40.0);
    });
  });

  group('ShiftParser', () {
    test('parse standard format correctly', () {
      const input = "24.6 - 17:30 - 23:00";
      final shift = ShiftParser.parse(input, 'j1');

      expect(shift, isNotNull);
      expect(shift!.startTime.hour, 17);
      expect(shift.startTime.minute, 30);
      expect(shift.endTime.hour, 23);
      expect(shift.endTime.minute, 0);
    });

    test('parse with tips correctly', () {
      const input = "22.7 - 07:00 - 13:00 + 50 tip";
      final shift = ShiftParser.parse(input, 'j1');

      expect(shift, isNotNull);
      expect(shift!.tips, 50.0);
    });

    test('handle invalid input gracefully', () {
      expect(ShiftParser.parse("invalid input", 'j1'), isNull);
    });
  });

  group('Shift Wage Segments', () {
    test(
      'calculate pay correctly with percentage segments (e.g. 150% then 100%)',
      () {
        final start = DateTime(2026, 10, 3, 18, 0); // Saturday 18:00
        final end = DateTime(2026, 10, 4, 2, 0); // Sunday 02:00 (8 hours total)

        // Segment 1: 18:00 to 20:30 (2.5 hours) at 150%
        // Segment 2: 20:30 to 02:00 (5.5 hours) at 100%
        final shift = Shift(
          id: 's_seg',
          date: start,
          startTime: start,
          endTime: end,
          jobTypeId: 'j1',
          hourlyRate: 40.0,
          wageSegments: [
            ShiftWageSegment(
              startTime: DateTime(2026, 10, 3, 18, 0),
              endTime: DateTime(2026, 10, 3, 20, 30),
              percentage: 150.0,
            ),
            ShiftWageSegment(
              startTime: DateTime(2026, 10, 3, 20, 30),
              endTime: DateTime(2026, 10, 4, 2, 0),
              percentage: 100.0,
            ),
          ],
        );

        // 2.5 hours * 40.0 * 1.5 = 150.0
        // 5.5 hours * 40.0 * 1.0 = 220.0
        // Total expected = 150.0 + 220.0 = 370.0
        expect(shift.calculateBaseSalary(40.0), 370.0);
      },
    );
  });
}
