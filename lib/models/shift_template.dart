import 'package:flutter/material.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:uuid/uuid.dart';

class ShiftTemplate {
  final String id;
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? jobTypeId;
  final BreakType breakType;
  final String? description;

  const ShiftTemplate({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.jobTypeId,
    this.breakType = BreakType.none,
    this.description,
  });

  ShiftTemplate copyWith({
    String? id,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? jobTypeId,
    BreakType? breakType,
    String? description,
  }) {
    return ShiftTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      jobTypeId: jobTypeId ?? this.jobTypeId,
      breakType: breakType ?? this.breakType,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startHour': startTime.hour,
    'startMinute': startTime.minute,
    'endHour': endTime.hour,
    'endMinute': endTime.minute,
    'jobTypeId': jobTypeId,
    'breakType': breakType.name,
    'description': description,
  };

  factory ShiftTemplate.fromJson(Map<String, dynamic> json) {
    return ShiftTemplate(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? '',
      startTime: TimeOfDay(
        hour: json['startHour'] as int? ?? 9,
        minute: json['startMinute'] as int? ?? 0,
      ),
      endTime: TimeOfDay(
        hour: json['endHour'] as int? ?? 17,
        minute: json['endMinute'] as int? ?? 0,
      ),
      jobTypeId: json['jobTypeId'] as String?,
      breakType: BreakType.values.firstWhere(
        (b) => b.name == json['breakType'],
        orElse: () => BreakType.none,
      ),
      description: json['description'] as String?,
    );
  }
}
