import 'dart:math';

import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/overtime_rules.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_salary_breakdown.dart';
import 'package:shiftly/models/shift_wage_segment.dart';

class OvertimeCalculator {
  /// Rounding helper for monetary amounts to 2 decimal places.
  static double roundMonetary(double amount) {
    return (amount * 100).roundToDouble() / 100.0;
  }

  /// Calculates elapsed duration in hours with high precision.
  /// Handles overnight shifts spanning midnight.
  static double calculateGrossDurationHours(DateTime start, DateTime end) {
    var diff = end.difference(start).inSeconds / 3600.0;
    if (diff < 0) {
      diff += 24.0;
    }
    return diff;
  }

  /// Calculates unpaid break duration in hours.
  static double calculateUnpaidBreakHours(
    BreakType? breakType,
    double? unpaidBreakMinutes,
  ) {
    if ((breakType ?? BreakType.none) == BreakType.unpaid) {
      return (unpaidBreakMinutes ?? 45.0) / 60.0;
    }
    return 0.0;
  }

  /// Centralized calculation function that computes the full salary breakdown for a shift.
  static ShiftSalaryBreakdown calculateBreakdown({
    required DateTime startTime,
    required DateTime endTime,
    required double hourlyRate,
    BreakType? breakType,
    double unpaidBreakMinutes = 45.0,
    OvertimeRules rules = const OvertimeRules(),
    double tips = 0.0,
    double automaticIncomes = 0.0,
    double automaticExpenses = 0.0,
    List<ShiftWageSegment>? wageSegments,
  }) {
    final grossDurationHours = calculateGrossDurationHours(startTime, endTime);
    final unpaidBreakHours = calculateUnpaidBreakHours(
      breakType,
      unpaidBreakMinutes,
    );

    final netPaidHours = max(0.0, grossDurationHours - unpaidBreakHours);

    if (netPaidHours <= 0 || hourlyRate < 0) {
      return ShiftSalaryBreakdown(
        grossDurationHours: grossDurationHours,
        unpaidBreakHours: unpaidBreakHours,
        netPaidHours: 0.0,
        hourlyRate: max(0.0, hourlyRate),
        regularHours: 0.0,
        regularEarnings: 0.0,
        tier1Hours: 0.0,
        tier1Multiplier: rules.tier1Multiplier,
        tier1Earnings: 0.0,
        tier2Hours: 0.0,
        tier2Multiplier: rules.tier2Multiplier,
        tier2Earnings: 0.0,
        totalBaseSalary: 0.0,
        tips: tips,
        automaticIncomes: automaticIncomes,
        automaticExpenses: automaticExpenses,
        totalShiftPay: roundMonetary(
          tips + automaticIncomes - automaticExpenses,
        ),
      );
    }

    // If manual wage segments are provided, evaluate them directly
    if (wageSegments != null && wageSegments.isNotEmpty) {
      final grossDuration = grossDurationHours;
      final netRatio = grossDuration > 0 ? (netPaidHours / grossDuration) : 1.0;

      List<DateTime> points = [startTime, endTime];
      for (var seg in wageSegments) {
        DateTime segStart = seg.startTime.isBefore(startTime)
            ? startTime
            : (seg.startTime.isAfter(endTime) ? endTime : seg.startTime);
        DateTime segEnd = seg.endTime.isBefore(startTime)
            ? startTime
            : (seg.endTime.isAfter(endTime) ? endTime : seg.endTime);
        if (segStart.isBefore(segEnd)) {
          points.add(segStart);
          points.add(segEnd);
        }
      }
      points.sort();
      points = points.toSet().toList();

      double regHours = 0;
      double regEarn = 0;
      double t1Hours = 0;
      double t1Earn = 0;
      double t2Hours = 0;
      double t2Earn = 0;
      double t1Mult = rules.tier1Multiplier;
      double t2Mult = rules.tier2Multiplier;

      for (int i = 0; i < points.length - 1; i++) {
        DateTime t1 = points[i];
        DateTime t2 = points[i + 1];
        double grossSegHours = t2.difference(t1).inSeconds / 3600.0;
        if (grossSegHours <= 0) continue;
        double netSegHours = grossSegHours * netRatio;

        double percentage = 100.0;
        for (var seg in wageSegments) {
          if (!t1.isBefore(seg.startTime) && !t2.isAfter(seg.endTime)) {
            percentage = seg.percentage;
            break;
          }
        }

        double segEarnings = roundMonetary(
          netSegHours * hourlyRate * (percentage / 100.0),
        );
        if (percentage <= 100.0) {
          regHours += netSegHours;
          regEarn += segEarnings;
        } else if (percentage <= 125.0) {
          t1Hours += netSegHours;
          t1Earn += segEarnings;
          t1Mult = max(t1Mult, percentage / 100.0);
        } else {
          t2Hours += netSegHours;
          t2Earn += segEarnings;
          t2Mult = max(t2Mult, percentage / 100.0);
        }
      }

      final totalBaseSalary = roundMonetary(regEarn + t1Earn + t2Earn);
      final totalShiftPay = roundMonetary(
        totalBaseSalary + tips + automaticIncomes - automaticExpenses,
      );

      return ShiftSalaryBreakdown(
        grossDurationHours: grossDurationHours,
        unpaidBreakHours: unpaidBreakHours,
        netPaidHours: netPaidHours,
        hourlyRate: hourlyRate,
        regularHours: regHours,
        regularEarnings: regEarn,
        tier1Hours: t1Hours,
        tier1Multiplier: t1Mult,
        tier1Earnings: t1Earn,
        tier2Hours: t2Hours,
        tier2Multiplier: t2Mult,
        tier2Earnings: t2Earn,
        totalBaseSalary: totalBaseSalary,
        tips: tips,
        automaticIncomes: automaticIncomes,
        automaticExpenses: automaticExpenses,
        totalShiftPay: totalShiftPay,
      );
    }

    if (!rules.enabled || !rules.isValid) {
      final regularEarnings = roundMonetary(netPaidHours * hourlyRate);
      final totalPay = roundMonetary(
        regularEarnings + tips + automaticIncomes - automaticExpenses,
      );
      return ShiftSalaryBreakdown(
        grossDurationHours: grossDurationHours,
        unpaidBreakHours: unpaidBreakHours,
        netPaidHours: netPaidHours,
        hourlyRate: hourlyRate,
        regularHours: netPaidHours,
        regularEarnings: regularEarnings,
        tier1Hours: 0.0,
        tier1Multiplier: rules.tier1Multiplier,
        tier1Earnings: 0.0,
        tier2Hours: 0.0,
        tier2Multiplier: rules.tier2Multiplier,
        tier2Earnings: 0.0,
        totalBaseSalary: regularEarnings,
        tips: tips,
        automaticIncomes: automaticIncomes,
        automaticExpenses: automaticExpenses,
        totalShiftPay: totalPay,
      );
    }

    final regularHours = min(netPaidHours, rules.regularHoursThreshold);
    final remainingAfterRegular = max(
      0.0,
      netPaidHours - rules.regularHoursThreshold,
    );

    final tier1Hours = min(remainingAfterRegular, rules.tier1HoursLimit);
    final tier2Hours = max(0.0, remainingAfterRegular - rules.tier1HoursLimit);

    final regularEarnings = roundMonetary(regularHours * hourlyRate);
    final tier1Earnings = roundMonetary(
      tier1Hours * hourlyRate * rules.tier1Multiplier,
    );
    final tier2Earnings = roundMonetary(
      tier2Hours * hourlyRate * rules.tier2Multiplier,
    );

    final totalBaseSalary = roundMonetary(
      regularEarnings + tier1Earnings + tier2Earnings,
    );
    final totalShiftPay = roundMonetary(
      totalBaseSalary + tips + automaticIncomes - automaticExpenses,
    );

    return ShiftSalaryBreakdown(
      grossDurationHours: grossDurationHours,
      unpaidBreakHours: unpaidBreakHours,
      netPaidHours: netPaidHours,
      hourlyRate: hourlyRate,
      regularHours: regularHours,
      regularEarnings: regularEarnings,
      tier1Hours: tier1Hours,
      tier1Multiplier: rules.tier1Multiplier,
      tier1Earnings: tier1Earnings,
      tier2Hours: tier2Hours,
      tier2Multiplier: rules.tier2Multiplier,
      tier2Earnings: tier2Earnings,
      totalBaseSalary: totalBaseSalary,
      tips: tips,
      automaticIncomes: automaticIncomes,
      automaticExpenses: automaticExpenses,
      totalShiftPay: totalShiftPay,
    );
  }

  /// Calculates breakdown directly from an existing [Shift] model instance.
  static ShiftSalaryBreakdown calculateBreakdownForShift(
    Shift shift, {
    OvertimeRules rules = const OvertimeRules(),
    double fallbackRate = 40.0,
  }) {
    final rate = shift.effectiveHourlyRate(fallbackRate);
    return calculateBreakdown(
      startTime: shift.startTime,
      endTime: shift.endTime,
      hourlyRate: rate,
      breakType: shift.breakType,
      unpaidBreakMinutes: shift.unpaidBreakMinutes ?? 45.0,
      rules: rules,
      tips: shift.tips,
      automaticIncomes: shift.totalAutomaticIncomes,
      automaticExpenses: shift.totalAutomaticExpenses,
      wageSegments: shift.wageSegments,
    );
  }

  /// Generates mapped [ShiftWageSegment] objects for a shift based on overtime rules.
  static List<ShiftWageSegment> generateWageSegments({
    required DateTime startTime,
    required DateTime endTime,
    BreakType? breakType,
    double unpaidBreakMinutes = 45.0,
    OvertimeRules rules = const OvertimeRules(),
  }) {
    if (!rules.enabled || !rules.isValid) {
      return [];
    }

    final grossDurationHours = calculateGrossDurationHours(startTime, endTime);
    final unpaidBreakHours = calculateUnpaidBreakHours(
      breakType,
      unpaidBreakMinutes,
    );
    final netPaidHours = max(0.0, grossDurationHours - unpaidBreakHours);

    if (netPaidHours <= 0 || grossDurationHours <= 0) {
      return [];
    }

    // Ratio of net worked time to total elapsed time
    final netRatio = netPaidHours / grossDurationHours;

    final regularHours = min(netPaidHours, rules.regularHoursThreshold);
    final remainingAfterRegular = max(
      0.0,
      netPaidHours - rules.regularHoursThreshold,
    );
    final tier1Hours = min(remainingAfterRegular, rules.tier1HoursLimit);
    final tier2Hours = max(0.0, remainingAfterRegular - rules.tier1HoursLimit);

    final regularGrossHours = regularHours / netRatio;
    final tier1GrossHours = tier1Hours / netRatio;
    final tier2GrossHours = tier2Hours / netRatio;

    List<ShiftWageSegment> segments = [];

    DateTime current = startTime;

    if (regularGrossHours > 0) {
      final segEnd = current.add(
        Duration(milliseconds: (regularGrossHours * 3600 * 1000).round()),
      );
      segments.add(
        ShiftWageSegment(
          startTime: current,
          endTime: segEnd,
          percentage: 100.0,
        ),
      );
      current = segEnd;
    }

    if (tier1GrossHours > 0) {
      final segEnd = current.add(
        Duration(milliseconds: (tier1GrossHours * 3600 * 1000).round()),
      );
      segments.add(
        ShiftWageSegment(
          startTime: current,
          endTime: segEnd,
          percentage: rules.tier1Multiplier * 100.0,
        ),
      );
      current = segEnd;
    }

    if (tier2GrossHours > 0) {
      segments.add(
        ShiftWageSegment(
          startTime: current,
          endTime: endTime,
          percentage: rules.tier2Multiplier * 100.0,
        ),
      );
    }

    return segments;
  }
}
