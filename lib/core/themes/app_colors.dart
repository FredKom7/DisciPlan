import 'package:flutter/material.dart';

/// App color palette for dark theme
class AppColors {
  // Backgrounds
  static const background = Color(0xFF1A1A1A);
  static const cardBackground = Color(0xFF252525);
  static const surfaceLight = Color(0xFF2D2D2D);
  
  // Primary colors
  static const primary = Color(0xFF3B82F6); // Blue
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF2563EB);
  
  // Accent colors
  static const success = Color(0xFF10B981); // Green
  static const warning = Color(0xFFF59E0B); // Yellow/Orange
  static const error = Color(0xFFEF4444); // Red
  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFEC4899);
  
  // Text colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textTertiary = Color(0xFF6B7280);
  
  // Category colors
  static const categoryWork = Color(0xFF3B82F6); // Blue
  static const categoryHealth = Color(0xFF10B981); // Green
  static const categoryPersonal = Color(0xFF8B5CF6); // Purple
  static const categoryLearning = Color(0xFFF59E0B); // Yellow
  static const categorySocial = Color(0xFFEC4899); // Pink
  
  // Gradients
  static const gradientBlue = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const gradientGreen = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const gradientPurple = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const gradientProgress = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Utility
  static const divider = Color(0xFF374151);
  static const overlay = Color(0x40000000);
}

/// App spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// App border radius constants
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circular = 999.0;
}
