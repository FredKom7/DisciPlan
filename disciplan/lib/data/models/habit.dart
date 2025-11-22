class Habit {
  const Habit({
    required this.id,
    required this.name,
    this.isActive = true,
    this.streak = 0,
  });

  final String id;
  final String name;
  final bool isActive;
  final int streak;

  Habit copyWith({
    String? id,
    String? name,
    bool? isActive,
    int? streak,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      streak: streak ?? this.streak,
    );
  }
}

