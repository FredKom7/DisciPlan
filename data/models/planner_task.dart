import 'package:hive/hive.dart';
part 'planner_task.g.dart';

@HiveType(typeId: 1)
class PlannerTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  int priority; // 0: low, 1: medium, 2: high

  @HiveField(5)
  DateTime date; // The day this task is scheduled for

  @HiveField(6)
  DateTime createdAt;

  PlannerTask({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = 1,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
} 