import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform detection and utility class for cross-platform compatibility
class PlatformUtils {
  // Platform detection
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  
  // Platform groups
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
  
  /// Get platform name as string
  static String getPlatformName() {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWeb) return 'Web';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }
  
  /// Check if platform supports a specific feature
  static bool supportsFeature(PlatformFeature feature) {
    switch (feature) {
      case PlatformFeature.appBlocking:
        return isAndroid; // Only Android supports app blocking
      
      case PlatformFeature.phoneAuth:
        return isAndroid || isIOS; // Phone auth works on mobile
      
      case PlatformFeature.notifications:
        return !isWeb; // All platforms except web have full notification support
      
      case PlatformFeature.localStorage:
        return true; // All platforms support local storage
      
      case PlatformFeature.firestore:
        return true; // All platforms support Firestore
      
      case PlatformFeature.backgroundSync:
        return isMobile; // Background sync works best on mobile
      
      case PlatformFeature.biometricAuth:
        return isMobile; // Biometric auth is mobile-only
      
      default:
        return false;
    }
  }
  
  /// Get appropriate storage path for platform
  static String getStoragePath() {
    if (isWeb) return 'web_storage';
    if (isAndroid) return 'android_storage';
    if (isIOS) return 'ios_storage';
    if (isWindows) return 'windows_storage';
    return 'default_storage';
  }
  
  /// Check if running on physical device (vs emulator/simulator)
  static bool get isPhysicalDevice {
    // This is a simplified check - for production, use device_info_plus package
    return !kIsWeb;
  }
}

/// Enum for platform features
enum PlatformFeature {
  appBlocking,
  phoneAuth,
  notifications,
  localStorage,
  firestore,
  backgroundSync,
  biometricAuth,
}
