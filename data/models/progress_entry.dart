import 'package:hive/hive.dart';
part 'progress_entry.g.dart';

@HiveType(typeId: 5)
class ProgressEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int completedTasks;

  @HiveField(3)
  int completedHabits;

  @HiveField(4)
  int screenTimeMinutes;

  @HiveField(5)
  DateTime createdAt;

  ProgressEntry({
    required this.id,
    required this.date,
    this.completedTasks = 0,
    this.completedHabits = 0,
    this.screenTimeMinutes = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
} 