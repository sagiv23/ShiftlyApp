// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_wage_segment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftWageSegmentAdapter extends TypeAdapter<ShiftWageSegment> {
  @override
  final int typeId = 6;

  @override
  ShiftWageSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShiftWageSegment(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
      percentage: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ShiftWageSegment obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.percentage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftWageSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
