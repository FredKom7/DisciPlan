// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressEntryAdapter extends TypeAdapter<ProgressEntry> {
  @override
  final int typeId = 5;

  @override
  ProgressEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      completedTasks: fields[2] as int,
      completedHabits: fields[3] as int,
      screenTimeMinutes: fields[4] as int,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.completedTasks)
      ..writeByte(3)
      ..write(obj.completedHabits)
      ..writeByte(4)
      ..write(obj.screenTimeMinutes)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
