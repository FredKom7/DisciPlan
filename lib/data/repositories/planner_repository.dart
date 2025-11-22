import 'package:hive/hive.dart';
import '../models/planner_task.dart';

class PlannerRepository {
  static const String boxName = 'planner_tasks';

  Future<List<PlannerTask>> getTasksForWeek(DateTime weekStart) async {
    final box = await Hive.openBox<PlannerTask>(boxName);
    return box.values.where((task) {
      final diff = task.date.difference(weekStart).inDays;
      return diff >= 0 && diff < 7;
    }).toList();
  }

  Future<List<PlannerTask>> getTasksForMonth(DateTime monthStart) async {
    final box = await Hive.openBox<PlannerTask>(boxName);
    return box.values.where((task) =>
      task.date.year == monthStart.year && task.date.month == monthStart.month).toList();
  }

  Future<void> addTask(PlannerTask task) async {
    final box = await Hive.openBox<PlannerTask>(boxName);
    await box.put(task.id, task);
  }

  Future<void> updateTask(PlannerTask task) async {
    final box = await Hive.openBox<PlannerTask>(boxName);
    await box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    final box = await Hive.openBox<PlannerTask>(boxName);
    await box.delete(id);
  }
} 