class PlannerTask {
  const PlannerTask({
    required this.id,
    required this.title,
    required this.date,
    this.frequency = TaskFrequency.daily,
    this.isCompleted = false,
    this.notes,
  });

  final String id;
  final String title;
  final DateTime date;
  final TaskFrequency frequency;
  final bool isCompleted;
  final String? notes;

  PlannerTask copyWith({
    String? id,
    String? title,
    DateTime? date,
    TaskFrequency? frequency,
    bool? isCompleted,
    String? notes,
  }) {
    return PlannerTask(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      frequency: frequency ?? this.frequency,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}

enum TaskFrequency { daily, weekly, monthly }

