import 'package:hive/hive.dart';
part 'screen_time_entry.g.dart';

@HiveType(typeId: 3)
class ScreenTimeEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String appName;

  @HiveField(2)
  String category; // productive, neutral, distracting

  @HiveField(3)
  int durationMinutes; // in minutes

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  DateTime createdAt;

  ScreenTimeEntry({
    required this.id,
    required this.appName,
    required this.category,
    required this.durationMinutes,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}