import 'package:hive/hive.dart';
import '../models/habit.dart';

class HabitRepository {
  static const String boxName = 'habits';

  Future<List<Habit>> getHabits() async {
    final box = await Hive.openBox<Habit>(boxName);
    return box.values.toList();
  }

  Future<void> addHabit(Habit habit) async {
    final box = await Hive.openBox<Habit>(boxName);
    await box.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    final box = await Hive.openBox<Habit>(boxName);
    await box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    final box = await Hive.openBox<Habit>(boxName);
    await box.delete(id);
  }
} 