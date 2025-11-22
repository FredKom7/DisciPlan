import 'package:flutter/material.dart';
import '../data/models/planner_task.dart';
import '../data/repositories/planner_repository.dart';

class PlannerProvider extends ChangeNotifier {
  final PlannerRepository _repository = PlannerRepository();
  List<PlannerTask> _tasks = [];

  List<PlannerTask> get tasks => _tasks;

  Future<void> loadTasksForWeek(DateTime weekStart) async {
    _tasks = await _repository.getTasksForWeek(weekStart);
    notifyListeners();
  }

  Future<void> addTask(PlannerTask task, DateTime weekStart) async {
    await _repository.addTask(task);
    await loadTasksForWeek(weekStart);
  }

  Future<void> updateTask(PlannerTask task, DateTime weekStart) async {
    await _repository.updateTask(task);
    await loadTasksForWeek(weekStart);
  }

  Future<void> deleteTask(String id, DateTime weekStart) async {
    await _repository.deleteTask(id);
    await loadTasksForWeek(weekStart);
  }
} 