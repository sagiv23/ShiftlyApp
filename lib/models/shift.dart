import 'package:hive/hive.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/shift_wage_segment.dart';
import 'package:shiftly/utils/app_constants.dart';

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

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
    id: json['id'],
    date: DateTime.parse(json['date']),
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    jobTypeId: json['jobTypeId'],
    tips: json['tips']?.toDouble() ?? 0.0,
    individualTips: (json['individualTips'] as List?)
        ?.map((e) => (e as num).toDouble())
        .toList(),
    breakType: json['breakType'] != null
        ? BreakType.values.firstWhere(
            (e) => e.toString() == json['breakType'],
            orElse: () => BreakType.none,
          )
        : BreakType.none,
    unpaidBreakMinutes: json['unpaidBreakMinutes']?.toDouble(),
    hourlyRate: json['hourlyRate']?.toDouble(),
    automaticExpenses: (json['automaticExpenses'] as List?)
        ?.map(
          (e) => AutomaticExpense.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
    automaticIncomes: (json['automaticIncomes'] as List?)
        ?.map(
          (e) => AutomaticExpense.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
    description: json['description'],
    wageSegments: (json['wageSegments'] as List?)
        ?.map(
          (e) => ShiftWageSegment.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
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
  double effectiveHourlyRate([double fallbackRate = AppConstants.defaultHourlyRate]) {
    return hourlyRate ?? fallbackRate;
  }

  double calculateBaseSalary(double currentHourlyRate) {
    final rate = effectiveHourlyRate(currentHourlyRate);
    if (wageSegments == null || wageSegments!.isEmpty) {
      return netHours * rate;
    }

    final grossDuration = durationHours;
    if (grossDuration <= 0) return 0.0;

    final netRatio = netHours / grossDuration;

    List<DateTime> points = [startTime, endTime];
    for (var seg in wageSegments!) {
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

    double totalWeightedPay = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      DateTime t1 = points[i];
      DateTime t2 = points[i + 1];
      double hours = t2.difference(t1).inSeconds / 3600.0;
      if (hours <= 0) continue;

      double percentage = 100.0; // default
      for (var seg in wageSegments!) {
        if (!t1.isBefore(seg.startTime) && !t2.isAfter(seg.endTime)) {
          percentage = seg.percentage;
          break;
        }
      }

      totalWeightedPay += hours * rate * (percentage / 100.0);
    }

    return totalWeightedPay * netRatio;
  }

  double calculateTotalPay(double currentHourlyRate) {
    return calculateBaseSalary(currentHourlyRate) +
        tips +
        totalAutomaticIncomes -
        totalAutomaticExpenses;
  }
}

