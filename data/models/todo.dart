import 'package:hive/hive.dart';
part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
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
  String category;

  @HiveField(6)
  DateTime? deadline;

  @HiveField(7)
  DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = 1,
    this.category = '',
    this.deadline,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
} 