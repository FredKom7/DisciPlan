import 'package:hive/hive.dart';
import '../models/screen_time_entry.dart';

class ScreenTimeRepository {
  static const String boxName = 'screen_time_entries';

  Future<Box<ScreenTimeEntry>> _getBox() async {
    return await Hive.openBox<ScreenTimeEntry>(boxName);
  }

  Future<List<ScreenTimeEntry>> getEntriesForDate(DateTime date) async {
    final box = await _getBox();
    return box.values
        .where((entry) => entry.date.year == date.year && entry.date.month == date.month && entry.date.day == date.day)
        .toList();
  }

  Future<void> addEntry(ScreenTimeEntry entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  Future<void> updateEntry(ScreenTimeEntry entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
} 