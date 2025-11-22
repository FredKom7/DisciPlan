class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    this.note,
    required this.createdAt,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String? note;
  final DateTime createdAt;
  final bool isCompleted;

  TodoItem copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

