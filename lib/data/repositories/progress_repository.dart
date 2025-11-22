import 'package:hive/hive.dart';
import '../models/progress_entry.dart';

class ProgressRepository {
  static const String boxName = 'progress_entries';

  Future<List<ProgressEntry>> getEntriesForMonth(DateTime month) async {
    final box = await Hive.openBox<ProgressEntry>(boxName);
    return box.values.where((entry) =>
      entry.date.year == month.year && entry.date.month == month.month).toList();
  }
} 