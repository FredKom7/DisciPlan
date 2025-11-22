import 'package:flutter/material.dart';
import '../data/models/progress_entry.dart';
import '../data/repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _repository = ProgressRepository();
  List<ProgressEntry> _entries = [];

  List<ProgressEntry> get entries => _entries;

  int get totalCompletedTasks => _entries.fold(0, (sum, e) => sum + e.completedTasks);
  int get totalCompletedHabits => _entries.fold(0, (sum, e) => sum + e.completedHabits);
  int get totalScreenTime => _entries.fold(0, (sum, e) => sum + e.screenTimeMinutes);

  Future<void> loadEntriesForMonth(DateTime month) async {
    _entries = await _repository.getEntriesForMonth(month);
    notifyListeners();
  }
} 