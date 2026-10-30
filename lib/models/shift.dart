import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/overtime_rules.dart';
import 'package:shiftly/models/shabbat_holiday_rules.dart';
import 'package:shiftly/models/shift_salary_breakdown.dart';
import 'package:shiftly/models/shift_wage_segment.dart';
import 'package:shiftly/services/overtime_calculator.dart';
import 'package:shiftly/utils/app_constants.dart';
import 'package:shiftly/utils/number_utils.dart';

import 'break_type.dart';

part 'shift.g.dart';

@HiveType(typeId: 1)
class Shift extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime endTime;

  @HiveField(4)
  String jobTypeId;

  @HiveField(5)
  double tips;

  @HiveField(7)
  BreakType? breakType;

  @HiveField(8)
  double? unpaidBreakMinutes;

  @HiveField(9)
  List<double>? individualTips;

  @HiveField(10)
  double? hourlyRate;

  @HiveField(11)
  double? automaticExpense; // Deprecated but kept for migration

  @HiveField(12)
  List<AutomaticExpense>? automaticExpenses;

  @HiveField(13)
  List<AutomaticExpense>? automaticIncomes;

  @HiveField(14)
  String? description;

  @HiveField(15)
  List<ShiftWageSegment>? wageSegments;

  Shift({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.jobTypeId,
    this.tips = 0.0,
    this.breakType = BreakType.none,
    this.unpaidBreakMinutes = 45.0,
    this.individualTips,
    this.hourlyRate,
    this.automaticExpense = 0.0,
    this.automaticExpenses,
    this.automaticIncomes,
    this.description,
    this.wageSegments,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'jobTypeId': jobTypeId,
    'tips': tips,
    'individualTips': individualTips,
    'breakType': breakType?.toString(),
    'unpaidBreakMinutes': unpaidBreakMinutes,
    'hourlyRate': hourlyRate,
    'automaticExpenses': automaticExpenses?.map((e) => e.toJson()).toList(),
    'automaticIncomes': automaticIncomes?.map((e) => e.toJson()).toList(),
    'description': description,
    'wageSegments': wageSegments?.map((e) => e.toJson()).toList(),
  };

  static List<AutomaticExpense>? _parseAutoList(dynamic raw) {
    if (raw == null) return null;
    try {
      List list;
      if (raw is String) {
        list = jsonDecode(raw) as List;
      } else if (raw is List) {
        list = raw;
      } else {
        return null;
      }
      return list
          .map(
            (e) =>
                AutomaticExpense.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  static List<ShiftWageSegment>? _parseWageSegments(dynamic raw) {
    if (raw == null) return null;
    try {
      List list;
      if (raw is String) {
        list = jsonDecode(raw) as List;
      } else if (raw is List) {
        list = raw;
      } else {
        return null;
      }
      return list
          .map(
            (e) =>
                ShiftWageSegment.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
    id: json['id'],
    date: DateTime.parse(json['date']),
    startTime: DateTime.parse(json['startTime'] ?? json['start_time']),
    endTime: DateTime.parse(json['endTime'] ?? json['end_time']),
    jobTypeId: json['jobTypeId'] ?? json['job_type_id'],
    tips: NumberUtils.parseDouble(json['tips']),
    individualTips: (json['individualTips'] as List?)
        ?.map((e) => NumberUtils.parseDouble(e))
        .toList(),
    breakType: json['breakType'] != null || json['break_type'] != null
        ? BreakType.values.firstWhere(
            (e) =>
                e.toString() == json['breakType'] ||
                e.toString().split('.').last.toLowerCase() ==
                    (json['break_type'] ?? '').toString().toLowerCase(),
            orElse: () => BreakType.none,
          )
        : BreakType.none,
    unpaidBreakMinutes: NumberUtils.parseDouble(
      json['unpaidBreakMinutes'] ?? json['unpaid_break_minutes'],
      45.0,
    ),
    hourlyRate: NumberUtils.parseNullableDouble(
      json['hourlyRate'] ?? json['hourly_rate'],
    ),
    automaticExpenses: _parseAutoList(
      json['automaticExpenses'] ?? json['automatic_expenses'],
    ),
    automaticIncomes: _parseAutoList(
      json['automaticIncomes'] ?? json['automatic_incomes'],
    ),
    description: json['description'],
    wageSegments: _parseWageSegments(
      json['wageSegments'] ?? json['wage_segments'],
    ),
  );

  double get totalAutomaticExpenses {
    double total = automaticExpense ?? 0.0;
    if (automaticExpenses != null) {
      for (var e in automaticExpenses!) {
        total += e.amount;
      }
    }
    return total;
  }

  double get totalAutomaticIncomes {
    double total = 0.0;
    if (automaticIncomes != null) {
      for (var e in automaticIncomes!) {
        total += e.amount;
      }
    }
    return total;
  }

  double get durationHours {
    // Use seconds for high precision, especially for short timer-based shifts
    var diff = endTime.difference(startTime).inSeconds / 3600.0;
    if (diff < 0) {
      // Overnight shift support
      diff += 24.0;
    }
    return diff;
  }

  double get netHours {
    double net;
    if ((breakType ?? BreakType.none) == BreakType.unpaid) {
      net = durationHours - ((unpaidBreakMinutes ?? 45.0) / 60.0);
    } else {
      net = durationHours;
    }
    return net < 0 ? 0.0 : net;
  }

  /// Prefer the snapshotted rate; fall back to [fallbackRate] for legacy shifts.
  double effectiveHourlyRate([
    double fallbackRate = AppConstants.defaultHourlyRate,
  ]) {
    return hourlyRate ?? fallbackRate;
  }

  double calculateBaseSalary(
    double currentHourlyRate, {
    OvertimeRules rules = const OvertimeRules(),
    ShabbatHolidayRules shabbatRules = const ShabbatHolidayRules(
      enabled: false,
    ),
  }) {
    if (!rules.enabled &&
        !shabbatRules.enabled &&
        (wageSegments == null || wageSegments!.isEmpty)) {
      return netHours * effectiveHourlyRate(currentHourlyRate);
    }
    return getSalaryBreakdown(
      rules: rules,
      shabbatRules: shabbatRules,
      fallbackRate: currentHourlyRate,
    ).totalBaseSalary;
  }

  double calculateTotalPay(
    double currentHourlyRate, {
    OvertimeRules rules = const OvertimeRules(),
    ShabbatHolidayRules shabbatRules = const ShabbatHolidayRules(
      enabled: false,
    ),
  }) {
    return calculateBaseSalary(
          currentHourlyRate,
          rules: rules,
          shabbatRules: shabbatRules,
        ) +
        tips +
        totalAutomaticIncomes -
        totalAutomaticExpenses;
  }

  ShiftSalaryBreakdown getSalaryBreakdown({
    OvertimeRules rules = const OvertimeRules(),
    ShabbatHolidayRules shabbatRules = const ShabbatHolidayRules(
      enabled: false,
    ),
    double fallbackRate = AppConstants.defaultHourlyRate,
  }) {
    return OvertimeCalculator.calculateBreakdownForShift(
      this,
      rules: rules,
      shabbatHolidayRules: shabbatRules,
      fallbackRate: fallbackRate,
    );
  }
}
