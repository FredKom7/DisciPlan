import 'package:flutter/material.dart';
import '../data/models/progress_entry.dart';
import '../data/repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _repository = ProgressRepository();
  List<ProgressEntry> _entries = [];

  List<ProgressEntry> get entries => _entries;

  Future<void> loadEntriesForMonth(DateTime month) async {
    _entries = await _repository.getEntriesForMonth(month);
    notifyListeners();
  }

  Future<void> addOrUpdateEntry(ProgressEntry entry, DateTime month) async {
    await _repository.addOrUpdateEntry(entry);
    await loadEntriesForMonth(month);
  }

  Future<void> deleteEntry(String id, DateTime month) async {
    await _repository.deleteEntry(id);
    await loadEntriesForMonth(month);
  }

  int get totalCompletedTasks => _entries.fold(0, (sum, e) => sum + e.completedTasks);
  int get totalCompletedHabits => _entries.fold(0, (sum, e) => sum + e.completedHabits);
  int get totalScreenTime => _entries.fold(0, (sum, e) => sum + e.screenTimeMinutes);
} 