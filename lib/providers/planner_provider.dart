import 'package:flutter/material.dart';
import '../data/models/planner_task.dart';
import '../data/repositories/planner_repository.dart';
import '../core/services/notification_service.dart';

class PlannerProvider extends ChangeNotifier {
  final PlannerRepository _repository = PlannerRepository();
  List<PlannerTask> _tasks = [];

  List<PlannerTask> get tasks => _tasks;

  List<PlannerTask> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      return task.date.year == date.year &&
             task.date.month == date.month &&
             task.date.day == date.day;
    }).toList();
  }

  Future<void> toggleTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final updatedTask = PlannerTask(
      id: task.id,
      title: task.title,
      description: task.description,
      date: task.date,
      isCompleted: !task.isCompleted,
      category: task.category,
    );
    await updateTask(updatedTask);
  }

  Future<void> loadTasksForWeek(DateTime weekStart) async {
    _tasks = await _repository.getTasksForWeek(weekStart);
    notifyListeners();
  }

  Future<void> loadTasksForMonth(DateTime monthStart) async {
    _tasks = await _repository.getTasksForMonth(monthStart);
    notifyListeners();
  }

  Future<void> addTask(PlannerTask task) async {
    await _repository.addTask(task);
    await loadTasksForWeek(task.date);
    await NotificationService.notifyTaskAdded(task.title, task.date);
  }

  Future<void> updateTask(PlannerTask task) async {
    final oldTask = _tasks.firstWhere((t) => t.id == task.id, orElse: () => task);
    final wasCompleted = oldTask.isCompleted;
    
    await _repository.updateTask(task);
    await loadTasksForWeek(task.date);
    
    if (!wasCompleted && task.isCompleted) {
      await NotificationService.notifyTaskCompleted(task.title);
    }
  }

  Future<void> deleteTask(String id, DateTime weekStart) async {
    await _repository.deleteTask(id);
    await loadTasksForWeek(weekStart);
  }
}