import 'package:hive/hive.dart';
import '../models/screen_time_entry.dart';

class ScreenTimeRepository {
  static const String boxName = 'screen_time_entries';

  Future<List<ScreenTimeEntry>> getEntriesForDate(DateTime date) async {
    final box = await Hive.openBox<ScreenTimeEntry>(boxName);
    return box.values.where((entry) =>
      entry.date.year == date.year && entry.date.month == date.month && entry.date.day == date.day).toList();
  }

  Future<void> addEntry(ScreenTimeEntry entry) async {
    final box = await Hive.openBox<ScreenTimeEntry>(boxName);
    await box.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    final box = await Hive.openBox<ScreenTimeEntry>(boxName);
    await box.delete(id);
  }
} 