import 'package:hive/hive.dart';
import '../models/planner_task.dart';

class PlannerRepository {
  static const String boxName = 'planner_tasks';

  Future<Box<PlannerTask>> _getBox() async {
    return await Hive.openBox<PlannerTask>(boxName);
  }

  Future<List<PlannerTask>> getTasksForWeek(DateTime weekStart) async {
    final box = await _getBox();
    final weekEnd = weekStart.add(const Duration(days: 6));
    return box.values
        .where((task) => task.date.isAfter(weekStart.subtract(const Duration(days: 1))) && task.date.isBefore(weekEnd.add(const Duration(days: 1))))
        .toList();
  }

  Future<void> addTask(PlannerTask task) async {
    final box = await _getBox();
    await box.put(task.id, task);
  }

  Future<void> updateTask(PlannerTask task) async {
    final box = await _getBox();
    await box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
} 