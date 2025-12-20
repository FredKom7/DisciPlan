// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_usage_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUsageStatsAdapter extends TypeAdapter<AppUsageStats> {
  @override
  final int typeId = 6;

  @override
  AppUsageStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUsageStats(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      usageTimeMinutes: fields[2] as int,
      date: fields[3] as DateTime,
      appIcon: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppUsageStats obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.usageTimeMinutes)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.appIcon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUsageStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
