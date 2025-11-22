// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_time_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScreenTimeEntryAdapter extends TypeAdapter<ScreenTimeEntry> {
  @override
  final int typeId = 3;

  @override
  ScreenTimeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScreenTimeEntry(
      id: fields[0] as String,
      appName: fields[1] as String,
      category: fields[2] as String,
      duration: fields[3] as int,
      date: fields[4] as DateTime,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ScreenTimeEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenTimeEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
