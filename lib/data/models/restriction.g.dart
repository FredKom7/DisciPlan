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
      appName: fields[1] as String,
      startTime: fields[2] as String,
      endTime: fields[3] as String,
      days: (fields[4] as List).cast<String>(),
      isActive: fields[5] as bool,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Restriction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.days)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.createdAt);
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
