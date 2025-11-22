import 'package:hive/hive.dart';
import '../models/habit.dart';

class HabitRepository {
  static const String boxName = 'habits';

  Future<Box<Habit>> _getBox() async {
    return await Hive.openBox<Habit>(boxName);
  }

  Future<List<Habit>> getHabits() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> addHabit(Habit habit) async {
    final box = await _getBox();
    await box.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    final box = await _getBox();
    await box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
} 