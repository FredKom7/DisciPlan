// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_restriction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppRestrictionAdapter extends TypeAdapter<AppRestriction> {
  @override
  final int typeId = 7;

  @override
  AppRestriction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppRestriction(
      id: fields[0] as String,
      packageName: fields[1] as String,
      appName: fields[2] as String,
      dailyLimitMinutes: fields[3] as int,
      restrictedDays: (fields[4] as List).cast<int>(),
      createdAt: fields[5] as DateTime,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppRestriction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.packageName)
      ..writeByte(2)
      ..write(obj.appName)
      ..writeByte(3)
      ..write(obj.dailyLimitMinutes)
      ..writeByte(4)
      ..write(obj.restrictedDays)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppRestrictionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
