import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/screen_time_entry.dart';
import '../data/models/app_usage_stats.dart';
import '../data/models/app_restriction.dart';
import '../data/repositories/screen_time_repository.dart';
import '../services/usage_stats_service.dart';

class ScreenTimeProvider extends ChangeNotifier {
  final ScreenTimeRepository _repository = ScreenTimeRepository();
  final UsageStatsService _usageStatsService = UsageStatsService();
  
  List<ScreenTimeEntry> _entries = [];
  List<AppUsageStats> _appUsageStats = [];
  List<AppRestriction> _restrictions = [];
  bool _hasPermission = false;
  bool _isLoading = false;

  List<ScreenTimeEntry> get entries => _entries;
  List<AppUsageStats> get appUsageStats => _appUsageStats;
  List<AppRestriction> get restrictions => _restrictions;
  bool get hasPermission => _hasPermission;
  bool get isLoading => _isLoading;

  ScreenTimeProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadRestrictions();
    await checkPermission();
  }

  Future<void> checkPermission() async {
    _hasPermission = await _usageStatsService.hasUsagePermission();
    notifyListeners();
  }

  Future<void> requestPermission() async {
    await _usageStatsService.requestUsagePermission();
    // Wait a bit for user to grant permission
    await Future.delayed(const Duration(seconds: 1));
    await checkPermission();
  }

  Future<void> loadEntriesForDate(DateTime date) async {
    _entries = await _repository.getEntriesForDate(date);
    notifyListeners();
  }

  Future<void> loadTodayUsageStats() async {
    if (!_hasPermission) {
      _appUsageStats = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _appUsageStats = await _usageStatsService.getTodayUsageStats();
      // Sort by usage time (descending)
      _appUsageStats.sort((a, b) => b.usageTimeMinutes.compareTo(a.usageTimeMinutes));
    } catch (e) {
      print('Error loading usage stats: $e');
      _appUsageStats = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUsageStatsForDate(DateTime date) async {
    if (!_hasPermission) {
      _appUsageStats = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _appUsageStats = await _usageStatsService.getUsageStatsForDate(date);
      // Sort by usage time (descending)
      _appUsageStats.sort((a, b) => b.usageTimeMinutes.compareTo(a.usageTimeMinutes));
    } catch (e) {
      print('Error loading usage stats: $e');
      _appUsageStats = [];
    }

    _isLoading = false;
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

  // Restriction management
  Future<void> _loadRestrictions() async {
    try {
      final box = await Hive.openBox<AppRestriction>('appRestrictions');
      _restrictions = box.values.toList();
      notifyListeners();
    } catch (e) {
      print('Error loading restrictions: $e');
      _restrictions = [];
    }
  }

  Future<void> addRestriction(AppRestriction restriction) async {
    try {
      final box = await Hive.openBox<AppRestriction>('appRestrictions');
      await box.put(restriction.packageName, restriction);
      await _loadRestrictions();
    } catch (e) {
      print('Error adding restriction: $e');
    }
  }

  Future<void> updateRestriction(AppRestriction restriction) async {
    try {
      final box = await Hive.openBox<AppRestriction>('appRestrictions');
      await box.put(restriction.packageName, restriction);
      await _loadRestrictions();
    } catch (e) {
      print('Error updating restriction: $e');
    }
  }

  Future<void> deleteRestriction(String packageName) async {
    try {
      final box = await Hive.openBox<AppRestriction>('appRestrictions');
      await box.delete(packageName);
      await _loadRestrictions();
    } catch (e) {
      print('Error deleting restriction: $e');
    }
  }

  AppRestriction? getRestrictionForPackage(String packageName) {
    try {
      return _restrictions.firstWhere((r) => r.packageName == packageName);
    } catch (e) {
      return null;
    }
  }

  bool hasRestriction(String packageName) {
    return _restrictions.any((r) => r.packageName == packageName && r.isActive);
  }

  bool isLimitExceeded(String packageName) {
    final restriction = getRestrictionForPackage(packageName);
    if (restriction == null || !restriction.isActive) return false;

    final usage = _appUsageStats.firstWhere(
      (stat) => stat.packageName == packageName,
      orElse: () => AppUsageStats(
        packageName: packageName,
        appName: '',
        usageTimeMinutes: 0,
        date: DateTime.now(),
      ),
    );

    return usage.usageTimeMinutes >= restriction.dailyLimitMinutes;
  }

  Map<String, int> getCategorySummary() {
    final summary = <String, int>{};
    for (final entry in _entries) {
      summary[entry.category] = (summary[entry.category] ?? 0) + entry.durationMinutes;
    }
    return summary;
  }

  // Get total screen time for today in minutes
  int getTodayTotal() {
    if (_appUsageStats.isNotEmpty) {
      return _appUsageStats.fold(0, (sum, stat) => sum + stat.usageTimeMinutes);
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _entries
        .where((entry) {
          final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
          return entryDate.isAtSameMomentAs(today);
        })
        .fold(0, (sum, entry) => sum + entry.durationMinutes);
  }
}