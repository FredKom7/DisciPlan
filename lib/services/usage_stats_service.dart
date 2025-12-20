import 'package:flutter/services.dart';
import '../data/models/app_usage_stats.dart';

class UsageStatsService {
  static const MethodChannel _channel = MethodChannel('usage_stats');

  /// Check if the app has usage stats permission
  Future<bool> hasUsagePermission() async {
    try {
      print('DEBUG: Checking usage permission...');
      final result = await _channel.invokeMethod('hasUsagePermission');
      print('DEBUG: Has permission: $result');
      return result as bool;
    } catch (e) {
      print('Error checking usage permission: $e');
      return false;
    }
  }

  /// Request usage stats permission (opens Settings)
  Future<void> requestUsagePermission() async {
    try {
      print('DEBUG: Requesting usage permission...');
      await _channel.invokeMethod('requestUsagePermission');
      print('DEBUG: Permission request sent successfully');
    } catch (e) {
      print('ERROR requesting usage permission: $e');
      rethrow;
    }
  }

  /// Get usage statistics for a date range
  Future<List<AppUsageStats>> getUsageStats({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final result = await _channel.invokeMethod('getUsageStats', {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      });

      if (result == null) return [];

      final List<dynamic> statsList = result as List<dynamic>;
      return statsList.map((stat) {
        final Map<String, dynamic> statMap = Map<String, dynamic>.from(stat);
        return AppUsageStats(
          packageName: statMap['packageName'] as String,
          appName: statMap['appName'] as String,
          usageTimeMinutes: statMap['usageTimeMinutes'] as int,
          date: DateTime.now(),
          appIcon: statMap['appIcon'] as String?,
        );
      }).toList();
    } catch (e) {
      print('Error getting usage stats: $e');
      return [];
    }
  }

  /// Get list of all installed apps
  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      
      if (result == null) return [];

      final List<dynamic> appsList = result as List<dynamic>;
      return appsList.map((app) => Map<String, dynamic>.from(app)).toList();
    } catch (e) {
      print('Error getting installed apps: $e');
      return [];
    }
  }

  /// Get usage stats for today
  Future<List<AppUsageStats>> getTodayUsageStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return getUsageStats(startTime: startOfDay, endTime: endOfDay);
  }

  /// Get usage stats for a specific date
  Future<List<AppUsageStats>> getUsageStatsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return getUsageStats(startTime: startOfDay, endTime: endOfDay);
  }
}
