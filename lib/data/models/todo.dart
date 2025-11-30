import 'package:hive/hive.dart';
part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  String priority; // 'Low', 'Medium', 'High'

  @HiveField(5)
  String category;

  @HiveField(6)
  DateTime? deadline;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String frequency; // 'daily', 'weekly', 'monthly'

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.category = '',
    this.deadline,
    DateTime? createdAt,
    this.frequency = 'daily',
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? priority,
    String? category,
    DateTime? deadline,
    String? frequency,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt,
    );
  }
}