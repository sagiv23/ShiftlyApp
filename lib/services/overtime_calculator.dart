import 'dart:math';

import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/overtime_rules.dart';
import 'package:shiftly/models/shabbat_holiday_rules.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_salary_breakdown.dart';
import 'package:shiftly/models/shift_wage_segment.dart';
import 'package:shiftly/services/shabbat_holiday_service.dart';

class OvertimeCalculator {
  /// Rounding helper for monetary amounts to 2 decimal places.
  static double roundMonetary(double amount) {
    return (amount * 100).roundToDouble() / 100.0;
  }

  /// Calculates elapsed duration in hours with high precision.
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
    ShabbatHolidayRules shabbatHolidayRules = const ShabbatHolidayRules(
      enabled: false,
    ),
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

    if (netPaidHours <= 0 || hourlyRate < 0 || grossDurationHours <= 0) {
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

    final netRatio = netPaidHours / grossDurationHours;

    // If manual wage segments are provided, evaluate them directly
    if (wageSegments != null && wageSegments.isNotEmpty) {
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

    // 1. Gather all special period boundaries (Shabbat & Holidays) if enabled
    List<SpecialPeriodBoundary> specialBoundaries = [];
    if (shabbatHolidayRules.enabled) {
      specialBoundaries = ShabbatHolidayService.getBoundariesForRange(
        startTime,
        endTime,
        shabbatHolidayRules,
      );
    }

    // 2. Build collection of interval split points
    List<DateTime> points = [startTime, endTime];
    for (var b in specialBoundaries) {
      if (b.start.isAfter(startTime) && b.start.isBefore(endTime)) {
        points.add(b.start);
      }
      if (b.end.isAfter(startTime) && b.end.isBefore(endTime)) {
        points.add(b.end);
      }
    }

    points.sort();
    points = points.toSet().toList();

    double regHours = 0;
    double regEarn = 0;
    double shabbatHours = 0;
    double shabbatEarn = 0;
    double holidayHours = 0;
    double holidayEarn = 0;
    String? holidayName;
    double holidayMult = 1.0;
    double shabbatMult = 1.0;

    double t1Hours = 0;
    double t1Earn = 0;
    double t2Hours = 0;
    double t2Earn = 0;
    double t1Mult = rules.tier1Multiplier;
    double t2Mult = rules.tier2Multiplier;

    // Track cumulative net paid hours across intervals for overtime threshold determination
    double cumulativeNetHours = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      DateTime t1 = points[i];
      DateTime t2 = points[i + 1];
      double grossSegHours = t2.difference(t1).inSeconds / 3600.0;
      if (grossSegHours <= 0) continue;
      double netSegHours = grossSegHours * netRatio;
      if (netSegHours <= 0) continue;

      // Determine special period status for this segment
      SpecialPeriodBoundary? activeBoundary;
      for (var b in specialBoundaries) {
        DateTime mid = t1.add(
          Duration(
            milliseconds: (t2.difference(t1).inMilliseconds / 2).round(),
          ),
        );
        if (b.contains(mid) ||
            (b.start.isAtSameMomentAs(t1) || b.end.isAtSameMomentAs(t2))) {
          activeBoundary = b;
          break;
        }
      }

      double specialMultiplier = 1.0;
      String periodType = 'regular';
      if (activeBoundary != null) {
        if (activeBoundary.type == 'shabbat') {
          specialMultiplier = activeBoundary.multiplier;
          periodType = 'shabbat';
          shabbatMult = max(shabbatMult, specialMultiplier);
        } else if (activeBoundary.type == 'holiday') {
          specialMultiplier = activeBoundary.multiplier;
          periodType = 'holiday';
          holidayName = activeBoundary.name;
          holidayMult = max(holidayMult, specialMultiplier);
        }
      }

      // Overtime calculation per interval based on cumulativeNetHours
      double threshold = rules.enabled && rules.isValid
          ? rules.regularHoursThreshold
          : double.infinity;
      double t1Limit = rules.enabled && rules.isValid
          ? rules.tier1HoursLimit
          : 0.0;

      double remainingNet = netSegHours;
      double segCursor = 0.0;

      while (remainingNet > 0.00001) {
        double currentNetTime = cumulativeNetHours + segCursor;
        double sliceHours = 0.0;
        double effectiveMultiplier = specialMultiplier;
        String tierType = periodType;

        if (rules.enabled && rules.isValid) {
          if (currentNetTime < threshold) {
            double spaceInReg = threshold - currentNetTime;
            sliceHours = min(remainingNet, spaceInReg);
          } else if (currentNetTime < threshold + t1Limit) {
            double spaceInT1 = (threshold + t1Limit) - currentNetTime;
            sliceHours = min(remainingNet, spaceInT1);
            tierType = 'tier1';

            effectiveMultiplier = _combineMultipliers(
              specialMultiplier,
              rules.tier1Multiplier,
              shabbatHolidayRules.combinationPolicy,
            );
            t1Mult = max(t1Mult, rules.tier1Multiplier);
          } else {
            sliceHours = remainingNet;
            tierType = 'tier2';

            effectiveMultiplier = _combineMultipliers(
              specialMultiplier,
              rules.tier2Multiplier,
              shabbatHolidayRules.combinationPolicy,
            );
            t2Mult = max(t2Mult, rules.tier2Multiplier);
          }
        } else {
          sliceHours = remainingNet;
        }

        if (sliceHours <= 0) break;

        double sliceEarnings = roundMonetary(
          sliceHours * hourlyRate * effectiveMultiplier,
        );

        if (tierType == 'tier1') {
          t1Hours += sliceHours;
          t1Earn += sliceEarnings;
        } else if (tierType == 'tier2') {
          t2Hours += sliceHours;
          t2Earn += sliceEarnings;
        } else if (tierType == 'shabbat') {
          shabbatHours += sliceHours;
          shabbatEarn += sliceEarnings;
        } else if (tierType == 'holiday') {
          holidayHours += sliceHours;
          holidayEarn += sliceEarnings;
        } else {
          regHours += sliceHours;
          regEarn += sliceEarnings;
        }

        segCursor += sliceHours;
        remainingNet -= sliceHours;
      }

      cumulativeNetHours += netSegHours;
    }

    final totalBaseSalary = roundMonetary(
      regEarn + shabbatEarn + holidayEarn + t1Earn + t2Earn,
    );
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
      shabbatHours: shabbatHours,
      shabbatMultiplier: shabbatMult,
      shabbatEarnings: shabbatEarn,
      holidayHours: holidayHours,
      holidayMultiplier: holidayMult,
      holidayEarnings: holidayEarn,
      holidayName: holidayName,
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

  /// Combines special day multiplier (Shabbat/Holiday) with Overtime multiplier according to policy.
  static double _combineMultipliers(
    double specialMultiplier,
    double overtimeMultiplier,
    String policy,
  ) {
    if (specialMultiplier <= 1.0) return overtimeMultiplier;
    if (overtimeMultiplier <= 1.0) return specialMultiplier;

    switch (policy) {
      case 'maxOfSpecialAndOvertime':
        return max(specialMultiplier, overtimeMultiplier);
      case 'addMultipliers':
        return specialMultiplier + overtimeMultiplier - 1.0;
      case 'specialDayMultiplierThenOvertime':
      default:
        return specialMultiplier * overtimeMultiplier;
    }
  }

  /// Calculates breakdown directly from an existing [Shift] model instance.
  static ShiftSalaryBreakdown calculateBreakdownForShift(
    Shift shift, {
    OvertimeRules rules = const OvertimeRules(),
    ShabbatHolidayRules shabbatHolidayRules = const ShabbatHolidayRules(),
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
      shabbatHolidayRules: shabbatHolidayRules,
      tips: shift.tips,
      automaticIncomes: shift.totalAutomaticIncomes,
      automaticExpenses: shift.totalAutomaticExpenses,
      wageSegments: shift.wageSegments,
    );
  }

  /// Generates mapped [ShiftWageSegment] objects for a shift based on rules.
  static List<ShiftWageSegment> generateWageSegments({
    required DateTime startTime,
    required DateTime endTime,
    BreakType? breakType,
    double unpaidBreakMinutes = 45.0,
    OvertimeRules rules = const OvertimeRules(),
    ShabbatHolidayRules shabbatHolidayRules = const ShabbatHolidayRules(),
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
