import 'package:hive/hive.dart';
part 'habit.g.dart';

@HiveType(typeId: 2)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int streak;

  @HiveField(4)
  DateTime? lastCompleted;

  @HiveField(5)
  DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.streak = 0,
    this.lastCompleted,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
} 