import 'package:hive/hive.dart';

part 'shift_wage_segment.g.dart';

@HiveType(typeId: 6)
class ShiftWageSegment extends HiveObject {
  @HiveField(0)
  DateTime startTime;

  @HiveField(1)
  DateTime endTime;

  @HiveField(2)
  double percentage; // e.g. 150.0 for 150%

  ShiftWageSegment({
    required this.startTime,
    required this.endTime,
    required this.percentage,
  });

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'percentage': percentage,
  };

  factory ShiftWageSegment.fromJson(Map<String, dynamic> json) =>
      ShiftWageSegment(
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        percentage: (json['percentage'] as num).toDouble(),
      );

  ShiftWageSegment copyWith({
    DateTime? startTime,
    DateTime? endTime,
    double? percentage,
  }) {
    return ShiftWageSegment(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      percentage: percentage ?? this.percentage,
    );
  }
}
