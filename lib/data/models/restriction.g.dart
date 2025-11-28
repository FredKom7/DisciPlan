// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restriction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RestrictionAdapter extends TypeAdapter<Restriction> {
  @override
  final int typeId = 4;

  @override
  Restriction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Restriction(
      id: fields[0] as String,
      type: fields[1] as String,
      target: fields[2] as String,
      limitMinutes: fields[3] as int?,
      isActive: fields[4] as bool,
      createdAt: fields[5] as DateTime?,
      startTime: fields[6] as DateTime?,
      endTime: fields[7] as DateTime?,
      scheduleType: fields[8] as String,
      activeDays: (fields[9] as List?)?.cast<int>(),
      dailyStartTime: fields[10] as String?,
      dailyEndTime: fields[11] as String?,
      durationMinutes: fields[12] as int?,
      packageName: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Restriction obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.target)
      ..writeByte(3)
      ..write(obj.limitMinutes)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.startTime)
      ..writeByte(7)
      ..write(obj.endTime)
      ..writeByte(8)
      ..write(obj.scheduleType)
      ..writeByte(9)
      ..write(obj.activeDays)
      ..writeByte(10)
      ..write(obj.dailyStartTime)
      ..writeByte(11)
      ..write(obj.dailyEndTime)
      ..writeByte(12)
      ..write(obj.durationMinutes)
      ..writeByte(13)
      ..write(obj.packageName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestrictionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
