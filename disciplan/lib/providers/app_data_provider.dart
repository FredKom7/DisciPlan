import 'dart:math';

import 'package:flutter/material.dart';

import '../data/models/habit.dart';
import '../data/models/planner_task.dart';
import '../data/models/progress_entry.dart';
import '../data/models/restriction.dart';
import '../data/models/screen_time_entry.dart';
import '../data/models/todo.dart';

class AppDataProvider extends ChangeNotifier {
  AppDataProvider() {
    _seedData();
  }

  final _random = Random();

  List<TodoItem> _todos = [];
  List<Habit> _habits = [];
  List<PlannerTask> _plannerTasks = [];
  List<ScreenTimeEntry> _screenTimeEntries = [];
  List<Restriction> _restrictions = [];
  List<ProgressEntry> _progressEntries = [];

  List<TodoItem> get todos => List.unmodifiable(_todos);
  List<Habit> get habits => List.unmodifiable(_habits);
  List<PlannerTask> get plannerTasks => List.unmodifiable(_plannerTasks);
  List<ScreenTimeEntry> get screenTimeEntries => List.unmodifiable(_screenTimeEntries);
  List<Restriction> get restrictions => List.unmodifiable(_restrictions);
  List<ProgressEntry> get progressEntries => List.unmodifiable(_progressEntries);

  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((todo) => todo.isCompleted).length;
  int get activeHabits => _habits.where((habit) => habit.isActive).length;
  int get todayTaskCount {
    final today = DateTime.now();
    return _plannerTasks
        .where((task) => _isSameDay(task.date, today))
        .length;
  }

  int get todaysScreenMinutes {
    final today = DateTime.now();
    return _screenTimeEntries
        .where((entry) => _isSameDay(entry.loggedAt, today))
        .fold(0, (sum, entry) => sum + entry.minutes);
  }

  void addTodo(String title, {String? note}) {
    _todos = [
      TodoItem(
        id: _newId(),
        title: title,
        note: note,
        createdAt: DateTime.now(),
      ),
      ..._todos,
    ];
    notifyListeners();
  }

  void toggleTodo(String id) {
    _todos = _todos
        .map((todo) => todo.id == id ? todo.copyWith(isCompleted: !todo.isCompleted) : todo)
        .toList();
    notifyListeners();
  }

  void removeTodo(String id) {
    _todos = _todos.where((todo) => todo.id != id).toList();
    notifyListeners();
  }

  void addHabit(String name) {
    _habits = [
      Habit(id: _newId(), name: name, isActive: true, streak: 0),
      ..._habits,
    ];
    notifyListeners();
  }

  void toggleHabitActivity(String id) {
    _habits = _habits
        .map((habit) =>
            habit.id == id ? habit.copyWith(isActive: !habit.isActive) : habit)
        .toList();
    notifyListeners();
  }

  void incrementHabitStreak(String id) {
    _habits = _habits
        .map((habit) => habit.id == id
            ? habit.copyWith(streak: habit.streak + 1, isActive: true)
            : habit)
        .toList();
    notifyListeners();
  }

  void addPlannerTask({
    required String title,
    required DateTime date,
    required TaskFrequency frequency,
    String? notes,
  }) {
    _plannerTasks = [
      PlannerTask(
        id: _newId(),
        title: title,
        date: date,
        frequency: frequency,
        notes: notes,
      ),
      ..._plannerTasks,
    ];
    notifyListeners();
  }

  void togglePlannerTask(String id) {
    _plannerTasks = _plannerTasks
        .map((task) => task.id == id
            ? task.copyWith(isCompleted: !task.isCompleted)
            : task)
        .toList();
    notifyListeners();
  }

  void removePlannerTask(String id) {
    _plannerTasks = _plannerTasks.where((task) => task.id != id).toList();
    notifyListeners();
  }

  void logScreenTime(String appName, int minutes, DateTime loggedAt) {
    _screenTimeEntries = [
      ScreenTimeEntry(
        id: _newId(),
        appName: appName,
        minutes: minutes,
        loggedAt: loggedAt,
      ),
      ..._screenTimeEntries,
    ];
    notifyListeners();
  }

  void addRestriction({
    required RestrictionType type,
    required String title,
    int? limitMinutes,
  }) {
    _restrictions = [
      Restriction(
        id: _newId(),
        title: title,
        type: type,
        limitMinutes: limitMinutes,
      ),
      ..._restrictions,
    ];
    notifyListeners();
  }

  void toggleRestriction(String id) {
    _restrictions = _restrictions
        .map((restriction) => restriction.id == id
            ? Restriction(
                id: restriction.id,
                title: restriction.title,
                type: restriction.type,
                limitMinutes: restriction.limitMinutes,
                isActive: !restriction.isActive,
              )
            : restriction)
        .toList();
    notifyListeners();
  }

  void _seedData() {
    _todos = [
      TodoItem(
        id: _newId(),
        title: 'Plan the week',
        note: 'Outline top 3 priorities.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TodoItem(
        id: _newId(),
        title: 'Meditation session',
        note: '15 minutes mindful breathing',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _habits = [
      Habit(id: _newId(), name: 'Morning Workout', streak: 4),
      Habit(id: _newId(), name: 'Reading (30m)', streak: 12),
      Habit(id: _newId(), name: 'No Sugar', streak: 2, isActive: false),
    ];

    final today = DateTime.now();
    _plannerTasks = [
      PlannerTask(
        id: _newId(),
        title: 'Deep work block',
        date: today,
        frequency: TaskFrequency.daily,
      ),
      PlannerTask(
        id: _newId(),
        title: 'Weekly review',
        date: today.add(const Duration(days: 2)),
        frequency: TaskFrequency.weekly,
      ),
      PlannerTask(
        id: _newId(),
        title: 'Budget check-in',
        date: today.add(const Duration(days: 5)),
        frequency: TaskFrequency.monthly,
      ),
    ];

    _screenTimeEntries = [
      ScreenTimeEntry(
        id: _newId(),
        appName: 'YouTube',
        minutes: 35,
        loggedAt: today.subtract(const Duration(hours: 1)),
      ),
      ScreenTimeEntry(
        id: _newId(),
        appName: 'Instagram',
        minutes: 12,
        loggedAt: today.subtract(const Duration(hours: 3)),
      ),
    ];

    _restrictions = [
      Restriction(
        id: _newId(),
        title: 'Reels limit',
        type: RestrictionType.shortForm,
        limitMinutes: 20,
      ),
      Restriction(
        id: _newId(),
        title: 'TikTok daily cap',
        type: RestrictionType.appLimit,
        limitMinutes: 30,
      ),
    ];

    _progressEntries = [
      ProgressEntry(
        id: _newId(),
        metric: 'Focus Score',
        percentage: 0.72,
        trend: Trend.up,
      ),
      ProgressEntry(
        id: _newId(),
        metric: 'Habit Consistency',
        percentage: 0.64,
        trend: Trend.steady,
      ),
      ProgressEntry(
        id: _newId(),
        metric: 'Screen Time Reduction',
        percentage: 0.48,
        trend: Trend.up,
      ),
    ];
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString() +
      _random.nextInt(999).toString();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

