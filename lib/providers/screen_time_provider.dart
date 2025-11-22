import 'package:flutter/material.dart';
import '../data/models/screen_time_entry.dart';
import '../data/repositories/screen_time_repository.dart';

class ScreenTimeProvider extends ChangeNotifier {
  final ScreenTimeRepository _repository = ScreenTimeRepository();
  List<ScreenTimeEntry> _entries = [];

  List<ScreenTimeEntry> get entries => _entries;

  Future<void> loadEntriesForDate(DateTime date) async {
    _entries = await _repository.getEntriesForDate(date);
    notifyListeners();
  }

  Future<void> addEntry(ScreenTimeEntry entry) async {
    await _repository.addEntry(entry);
    await loadEntriesForDate(entry.date);
  }

  Future<void> deleteEntry(String id, DateTime date) async {
    await _repository.deleteEntry(id);
    await loadEntriesForDate(date);
  }

  Map<String, int> getCategorySummary() {
    final summary = <String, int>{};
    for (final entry in _entries) {
      summary[entry.category] = (summary[entry.category] ?? 0) + entry.durationMinutes;
    }
    return summary;
  }
} 