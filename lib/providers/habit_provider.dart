import 'package:flutter/material.dart';
import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';
import '../core/services/notification_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  Future<void> loadHabits() async {
    _habits = await _repository.getHabits();
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await _repository.addHabit(habit);
    await loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    await _repository.updateHabit(habit);
    await loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    await _repository.deleteHabit(id);
    await loadHabits();
  }

  Future<void> markCompleted(Habit habit) async {
    final now = DateTime.now();
    final last = habit.lastCompleted;
    int newStreak = habit.streak;
    if (last != null &&
        DateTime(now.year, now.month, now.day)
            .difference(DateTime(last.year, last.month, last.day)) ==
            const Duration(days: 1)) {
      newStreak += 1;
    } else if (last == null ||
        DateTime(now.year, now.month, now.day)
            .difference(DateTime(last.year, last.month, last.day)) >
            const Duration(days: 1)) {
      newStreak = 1;
    }
    final updated = Habit(
      id: habit.id,
      name: habit.name,
      isCompleted: true,
      streak: newStreak,
      lastCompleted: now,
      createdAt: habit.createdAt,
    );
    await _repository.updateHabit(updated);
    await loadHabits();
    
    // Send notifications
    await NotificationService.notifyHabitCompleted(habit.name, newStreak);
    await NotificationService.notifyHabitStreak(habit.name, newStreak);
  }
}