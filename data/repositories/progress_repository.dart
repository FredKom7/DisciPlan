import 'package:hive/hive.dart';
import '../models/progress_entry.dart';

class ProgressRepository {
  static const String boxName = 'progress_entries';

  Future<Box<ProgressEntry>> _getBox() async {
    return await Hive.openBox<ProgressEntry>(boxName);
  }

  Future<List<ProgressEntry>> getEntriesForMonth(DateTime month) async {
    final box = await _getBox();
    return box.values
        .where((entry) => entry.date.year == month.year && entry.date.month == month.month)
        .toList();
  }

  Future<void> addOrUpdateEntry(ProgressEntry entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
} 