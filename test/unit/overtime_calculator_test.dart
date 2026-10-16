import 'package:flutter_test/flutter_test.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/overtime_rules.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/services/overtime_calculator.dart';

void main() {
  group('OvertimeCalculator Engine', () {
    const defaultRules = OvertimeRules(
      enabled: true,
      regularHoursThreshold: 8.0,
      tier1HoursLimit: 2.0,
      tier1Multiplier: 1.25,
      tier2Multiplier: 1.50,
    );

    test('1. Shift below regular threshold receives regular pay only', () {
      final start = DateTime(2026, 10, 16, 9, 0);
      final end = DateTime(2026, 10, 16, 15, 0); // 6 hours
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultRules,
      );

      expect(breakdown.grossDurationHours, 6.0);
      expect(breakdown.netPaidHours, 6.0);
      expect(breakdown.regularHours, 6.0);
      expect(breakdown.regularEarnings, 240.0);
      expect(breakdown.tier1Hours, 0.0);
      expect(breakdown.tier1Earnings, 0.0);
      expect(breakdown.tier2Hours, 0.0);
      expect(breakdown.tier2Earnings, 0.0);
      expect(breakdown.totalBaseSalary, 240.0);
      expect(breakdown.hasOvertime, false);
    });

    test('2. Shift exactly at threshold receives zero overtime pay', () {
      final start = DateTime(2026, 10, 16, 9, 0);
      final end = DateTime(2026, 10, 16, 17, 0); // 8 hours
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultRules,
      );

      expect(breakdown.netPaidHours, 8.0);
      expect(breakdown.regularHours, 8.0);
      expect(breakdown.regularEarnings, 320.0);
      expect(breakdown.tier1Hours, 0.0);
      expect(breakdown.tier2Hours, 0.0);
      expect(breakdown.totalBaseSalary, 320.0);
      expect(breakdown.hasOvertime, false);
    });

    test('3. Shift crossing first overtime threshold receives 125% pay', () {
      final start = DateTime(2026, 10, 16, 8, 0);
      final end = DateTime(2026, 10, 16, 18, 0); // 10 hours
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultRules,
      );

      expect(breakdown.netPaidHours, 10.0);
      expect(breakdown.regularHours, 8.0);
      expect(breakdown.regularEarnings, 320.0); // 8 * 40
      expect(breakdown.tier1Hours, 2.0);
      expect(breakdown.tier1Earnings, 100.0); // 2 * 40 * 1.25
      expect(breakdown.tier2Hours, 0.0);
      expect(breakdown.totalBaseSalary, 420.0); // 320 + 100
      expect(breakdown.hasOvertime, true);
    });

    test(
      '4. Shift crossing multiple overtime thresholds receives 125% and 150%',
      () {
        final start = DateTime(2026, 10, 16, 8, 0);
        final end = DateTime(2026, 10, 16, 20, 0); // 12 hours
        const rate = 40.0;

        final breakdown = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          rules: defaultRules,
        );

        expect(breakdown.netPaidHours, 12.0);
        expect(breakdown.regularHours, 8.0);
        expect(breakdown.regularEarnings, 320.0); // 8 * 40
        expect(breakdown.tier1Hours, 2.0);
        expect(breakdown.tier1Earnings, 100.0); // 2 * 40 * 1.25
        expect(breakdown.tier2Hours, 2.0);
        expect(breakdown.tier2Earnings, 120.0); // 2 * 40 * 1.50
        expect(breakdown.totalBaseSalary, 540.0); // 320 + 100 + 120
        expect(breakdown.hasOvertime, true);
      },
    );

    test(
      '5. Unpaid break is deducted correctly before evaluating overtime',
      () {
        final start = DateTime(2026, 10, 16, 8, 0);
        final end = DateTime(2026, 10, 16, 18, 45); // 10.75 gross hours
        const rate = 40.0;

        final breakdown = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          breakType: BreakType.unpaid,
          unpaidBreakMinutes: 45.0,
          // 0.75 hours
          rules: defaultRules,
        );

        expect(breakdown.grossDurationHours, 10.75);
        expect(breakdown.unpaidBreakHours, 0.75);
        expect(breakdown.netPaidHours, 10.0);
        expect(breakdown.regularHours, 8.0);
        expect(breakdown.tier1Hours, 2.0);
        expect(breakdown.tier2Hours, 0.0);
        expect(breakdown.totalBaseSalary, 420.0);
      },
    );

    test('6. Paid break is handled without unpaid deduction', () {
      final start = DateTime(2026, 10, 16, 8, 0);
      final end = DateTime(2026, 10, 16, 18, 0); // 10 gross hours
      const rate = 40.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        breakType: BreakType.paid,
        rules: defaultRules,
      );

      expect(breakdown.unpaidBreakHours, 0.0);
      expect(breakdown.netPaidHours, 10.0);
      expect(breakdown.totalBaseSalary, 420.0);
    });

    test('7. Overnight shift across midnight is calculated correctly', () {
      final start = DateTime(2026, 10, 16, 22, 0);
      final end = DateTime(2026, 10, 17, 8, 0); // 10 hours overnight
      const rate = 50.0;

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: rate,
        rules: defaultRules,
      );

      expect(breakdown.grossDurationHours, 10.0);
      expect(breakdown.netPaidHours, 10.0);
      expect(breakdown.regularHours, 8.0);
      expect(breakdown.tier1Hours, 2.0);
      expect(breakdown.regularEarnings, 400.0); // 8 * 50
      expect(breakdown.tier1Earnings, 125.0); // 2 * 50 * 1.25
      expect(breakdown.totalBaseSalary, 525.0);
    });

    test(
      '8. Repeated calculation produces identical deterministic results',
      () {
        final start = DateTime(2026, 10, 16, 9, 0);
        final end = DateTime(2026, 10, 16, 20, 0);
        const rate = 45.0;

        final res1 = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          rules: defaultRules,
        );
        final res2 = OvertimeCalculator.calculateBreakdown(
          startTime: start,
          endTime: end,
          hourlyRate: rate,
          rules: defaultRules,
        );

        expect(res1.totalShiftPay, res2.totalShiftPay);
        expect(res1.tier1Earnings, res2.tier1Earnings);
        expect(res1.tier2Earnings, res2.tier2Earnings);
      },
    );

    test(
      '9. Editing a shift updates overtime breakdown and total exactly once',
      () {
        final start = DateTime(2026, 10, 16, 8, 0);
        final end1 = DateTime(2026, 10, 16, 18, 0); // 10 hours
        final end2 = DateTime(2026, 10, 16, 20, 0); // 12 hours
        const rate = 40.0;

        final shift = Shift(
          id: 'edit_test',
          date: start,
          startTime: start,
          endTime: end1,
          jobTypeId: 'j1',
          hourlyRate: rate,
        );

        shift.wageSegments = OvertimeCalculator.generateWageSegments(
          startTime: start,
          endTime: end1,
          rules: defaultRules,
        );
        expect(shift.calculateBaseSalary(rate), 420.0);

        // Edit shift end time to 12 hours
        shift.endTime = end2;
        shift.wageSegments = OvertimeCalculator.generateWageSegments(
          startTime: start,
          endTime: end2,
          rules: defaultRules,
        );

        expect(shift.calculateBaseSalary(rate), 540.0);
      },
    );

    test(
      '10. Deleting a shift removes all its earnings from accumulated totals',
      () {
        final shift1 = Shift(
          id: 's1',
          date: DateTime(2026, 10, 1),
          startTime: DateTime(2026, 10, 1, 8),
          endTime: DateTime(2026, 10, 1, 18),
          // 10h = 420.0
          jobTypeId: 'j1',
          hourlyRate: 40.0,
          wageSegments: OvertimeCalculator.generateWageSegments(
            startTime: DateTime(2026, 10, 1, 8),
            endTime: DateTime(2026, 10, 1, 18),
            rules: defaultRules,
          ),
        );

        final shift2 = Shift(
          id: 's2',
          date: DateTime(2026, 10, 2),
          startTime: DateTime(2026, 10, 2, 8),
          endTime: DateTime(2026, 10, 2, 16),
          // 8h = 320.0
          jobTypeId: 'j1',
          hourlyRate: 40.0,
        );

        List<Shift> shiftsList = [shift1, shift2];
        double totalPay = shiftsList.fold(
          0.0,
          (sum, s) => sum + s.calculateTotalPay(40.0),
        );
        expect(totalPay, 740.0); // 420 + 320

        // Delete shift1
        shiftsList.removeWhere((s) => s.id == 's1');
        double totalAfterDelete = shiftsList.fold(
          0.0,
          (sum, s) => sum + s.calculateTotalPay(40.0),
        );
        expect(totalAfterDelete, 320.0);
      },
    );

    test('11. Reopening a saved shift retains exact breakdown and salary', () {
      final start = DateTime(2026, 10, 16, 8, 0);
      final end = DateTime(2026, 10, 16, 20, 0); // 12 hours
      const rate = 50.0;

      final shift = Shift(
        id: 'saved_shift',
        date: start,
        startTime: start,
        endTime: end,
        jobTypeId: 'j1',
        hourlyRate: rate,
        wageSegments: OvertimeCalculator.generateWageSegments(
          startTime: start,
          endTime: end,
          rules: defaultRules,
        ),
      );

      final jsonMap = shift.toJson();
      final reopenedShift = Shift.fromJson(jsonMap);

      expect(
        reopenedShift.calculateBaseSalary(rate),
        675.0,
      ); // (8*50) + (2*50*1.25) + (2*50*1.5) = 400 + 125 + 150 = 675
      expect(reopenedShift.wageSegments?.length, 3);
    });

    test('12. Shifts without overtime continue to work as before', () {
      final start = DateTime(2026, 10, 16, 9, 0);
      final end = DateTime(2026, 10, 16, 17, 0);
      final shift = Shift(
        id: 'normal',
        date: start,
        startTime: start,
        endTime: end,
        jobTypeId: 'j1',
        hourlyRate: 40.0,
      );

      expect(shift.calculateBaseSalary(40.0), 320.0);
      expect(shift.calculateTotalPay(40.0), 320.0);
    });

    test('13. Tips, expenses, and incomes remain separate and not doubled', () {
      final start = DateTime(2026, 10, 16, 8, 0);
      final end = DateTime(2026, 10, 16, 18, 0); // 10h -> base = 420.0

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: start,
        endTime: end,
        hourlyRate: 40.0,
        rules: defaultRules,
        tips: 50.0,
        automaticIncomes: 20.0,
        automaticExpenses: 15.0,
      );

      expect(breakdown.totalBaseSalary, 420.0);
      expect(breakdown.tips, 50.0);
      expect(breakdown.automaticIncomes, 20.0);
      expect(breakdown.automaticExpenses, 15.0);
      expect(breakdown.totalShiftPay, 475.0); // 420 + 50 + 20 - 15
    });

    test('14. Invalid overtime configuration is handled safely', () {
      const invalidRules = OvertimeRules(
        enabled: true,
        regularHoursThreshold: -5.0,
        tier1Multiplier: 0.5,
      );

      expect(invalidRules.isValid, false);

      final breakdown = OvertimeCalculator.calculateBreakdown(
        startTime: DateTime(2026, 10, 16, 8, 0),
        endTime: DateTime(2026, 10, 16, 18, 0),
        hourlyRate: 40.0,
        rules: invalidRules,
      );

      // Falls back safely to simple rate * hours
      expect(breakdown.netPaidHours, 10.0);
      expect(breakdown.totalBaseSalary, 400.0);
    });

    test(
      '15. Older existing shifts without overtime fields remain fully compatible',
      () {
        final legacyShift = Shift(
          id: 'legacy',
          date: DateTime(2020, 1, 1),
          startTime: DateTime(2020, 1, 1, 9, 0),
          endTime: DateTime(2020, 1, 1, 17, 0),
          jobTypeId: 'j1',
          hourlyRate: 35.0,
        );

        expect(legacyShift.wageSegments, isNull);
        expect(legacyShift.calculateBaseSalary(35.0), 280.0);
        expect(legacyShift.calculateTotalPay(35.0), 280.0);
      },
    );
  });
}
