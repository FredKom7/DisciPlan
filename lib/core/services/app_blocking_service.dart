import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../data/models/restriction.dart';
import '../utils/platform_utils.dart';

/// Service for managing app restrictions and blocking
/// 
/// On Android: Uses platform channels to communicate with native code
/// for true app blocking via AccessibilityService
/// 
/// On other platforms: Provides monitoring and logging capabilities
class AppBlockingService {
  static const MethodChannel _channel = MethodChannel('com.disciplan/app_blocking');
  
  /// Initialize the app blocking service
  /// On Android, this will request necessary permissions
  static Future<bool> initialize() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod('initialize');
        return result == true;
      } catch (e) {
        debugPrint('Error initializing app blocking service: $e');
        return false;
      }
    }
    return true; // On other platforms, always return true
  }

  /// Check if accessibility service is enabled (Android only)
  static Future<bool> isAccessibilityServiceEnabled() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod('isAccessibilityEnabled');
        return result == true;
      } catch (e) {
        debugPrint('Error checking accessibility service: $e');
        return false;
      }
    }
    return false;
  }

  /// Request accessibility service permission (Android only)
  static Future<void> requestAccessibilityPermission() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod('requestAccessibilityPermission');
      } catch (e) {
        debugPrint('Error requesting accessibility permission: $e');
      }
    }
  }

  /// Update the list of blocked apps
  static Future<void> updateBlockedApps(List<Restriction> activeRestrictions) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final blockedApps = activeRestrictions
            .where((r) => r.packageName != null && r.packageName!.isNotEmpty)
            .map((r) => {
                  'packageName': r.packageName,
                  'appName': r.target,
                  'timeRemaining': r.getTimeRemainingMinutes(),
                })
            .toList();

        await _channel.invokeMethod('updateBlockedApps', {'apps': blockedApps});
      } catch (e) {
        debugPrint('Error updating blocked apps: $e');
      }
    }
  }

  /// Clear all blocked apps
  static Future<void> clearBlockedApps() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod('clearBlockedApps');
      } catch (e) {
        debugPrint('Error clearing blocked apps: $e');
      }
    }
  }

  /// Log app access attempt (for monitoring on all platforms)
  static void logAppAccess(String appName, String packageName) {
    debugPrint('App access logged: $appName ($packageName)');
    // TODO: Store in local database for accountability reports
  }

  /// Get list of installed apps (Android only)
  static Future<List<Map<String, String>>> getInstalledApps() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod('getInstalledApps');
        if (result is List) {
          return result.map((app) => Map<String, String>.from(app as Map)).toList();
        }
      } catch (e) {
        debugPrint('Error getting installed apps: $e');
      }
    }
    return [];
  }

  /// Check if an app is currently running (Android only)
  static Future<bool> isAppRunning(String packageName) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod('isAppRunning', {'packageName': packageName});
        return result == true;
      } catch (e) {
        debugPrint('Error checking if app is running: $e');
        return false;
      }
    }
    return false;
  }
}
