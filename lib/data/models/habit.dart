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

  @HiveField(6)
  bool isActive;

  Habit({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.streak = 0,
    this.lastCompleted,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Habit copyWith({String? id, String? name, bool? isCompleted, int? streak, DateTime? lastCompleted, DateTime? createdAt, bool? isActive}) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      streak: streak ?? this.streak,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
} 