// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlannerTaskAdapter extends TypeAdapter<PlannerTask> {
  @override
  final int typeId = 1;

  @override
  PlannerTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannerTask(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      isCompleted: fields[3] as bool,
      priority: fields[4] as int,
      date: fields[5] as DateTime,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PlannerTask obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannerTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
