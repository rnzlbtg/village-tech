import 'package:flutter/material.dart';

/// Application color palette following Material 3 design system
/// Sentinel App - Security and access control theme
class AppColors {
  AppColors._();

  // ============== Primary Colors ==============
  /// Primary blue for main branding and actions
  static const Color primary = Color(0xFF1a73e8);
  static const Color onPrimary = Color(0xFFffffff);
  static const Color primaryContainer = Color(0xFFd3e3fd);
  static const Color onPrimaryContainer = Color(0xFF001d36);

  // ============== Secondary Colors ==============
  /// Secondary green for success states and confirmations
  static const Color secondary = Color(0xFF34a853);
  static const Color onSecondary = Color(0xFFffffff);
  static const Color secondaryContainer = Color(0xFFc8e6c9);
  static const Color onSecondaryContainer = Color(0xFF1b5e20);

  // ============== Tertiary Colors ==============
  /// Tertiary orange for warnings and alerts
  static const Color tertiary = Color(0xFFff9800);
  static const Color onTertiary = Color(0xFFffffff);
  static const Color tertiaryContainer = Color(0xFFfff3e0);
  static const Color onTertiaryContainer = Color(0xFFe65100);

  // ============== Surface Colors ==============
  static const Color surface = Color(0xFFffffff);
  static const Color onSurface = Color(0xFF1c1b1f);
  static const Color surfaceVariant = Color(0xFFe7e0ec);
  static const Color onSurfaceVariant = Color(0xFF49454f);
  static const Color surfaceTint = primary;
  static const Color inverseSurface = Color(0xFF313033);
  static const Color onInverseSurface = Color(0xFFF4EFF4);

  // ============== Background Colors ==============
  static const Color background = Color(0xFFfffbfe);
  static const Color onBackground = Color(0xFF1c1b1f);

  // ============== Status Colors ==============
  /// Success colors (access granted, verified)
  static const Color success = Color(0xFF34a853);
  static const Color successLight = Color(0xFFc8e6c9);
  static const Color onSuccess = Color(0xFFffffff);

  /// Error colors (access denied, invalid)
  static const Color error = Color(0xFFb00020);
  static const Color errorLight = Color(0xFFfde7e9);
  static const Color onError = Color(0xFFffffff);

  /// Warning colors (pending, attention needed)
  static const Color warning = Color(0xFFff9800);
  static const Color warningLight = Color(0xFFfff3e0);
  static const Color onWarning = Color(0xFF000000);

  /// Info colors (information, neutral)
  static const Color info = Color(0xFF2196f3);
  static const Color infoLight = Color(0xFFe3f2fd);
  static const Color onInfo = Color(0xFFffffff);

  // ============== Security-Specific Colors ==============
  /// Access granted color (green with security theme)
  static const Color accessGranted = Color(0xFF00c853);
  static const Color accessDenied = Color(0xFFd50000);
  static const Color accessPending = Color(0xFFffab00);

  /// RFID status colors
  static const Color rfidActive = Color(0xFF00c853);
  static const Color rfidExpired = Color(0xFFd50000);
  static const Color rfidRevoked = Color(0xFF9e9e9e);
  static const Color rfidLost = Color(0xFFff6f00);

  /// Priority levels for incidents and announcements
  static const Color priorityLow = Color(0xFF4caf50);
  static const Color priorityMedium = Color(0xFFff9800);
  static const Color priorityHigh = Color(0xFFf44336);
  static const Color priorityUrgent = Color(0xFF9c27b0);

  // ============== Border and Outline Colors ==============
  static const Color outline = Color(0xFF79747e);
  static const Color outlineVariant = Color(0xFFcac4d0);
  static const Color border = Color(0xFFe0e0e0);
  static const Color borderLight = Color(0xFFF5F5F5);

  // ============== Text Colors ==============
  static const Color textPrimary = Color(0xFF1c1b1f);
  static const Color textSecondary = Color(0xFF49454f);
  static const Color textDisabled = Color(0xFF938f99);
  static const Color textHint = Color(0xFF938f99);
  static const Color textOnDark = Color(0xFFffffff);

  // ============== Divider and Shadow Colors ==============
  static const Color divider = Color(0xFFe0e0e0);
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0F000000);

  // ============== Card and Container Colors ==============
  static const Color card = Color(0xFFffffff);
  static const Color cardSurface = Color(0xFFfafafa);
  static const Color elevatedSurface = Color(0xFFffffff);

  // ============== Bottom Navigation Colors ==============
  static const Color bottomNavBackground = Color(0xFFffffff);
  static const Color bottomNavSelected = primary;
  static const Color bottomNavUnselected = Color(0xFF757575);
  static const Color bottomNavIndicator = primary;

  // ============== Progress and Loading Colors ==============
  static const Color progressBackground = Color(0xFFe0e0e0);
  static const Color progressActive = primary;
  static const Color shimmer = Color(0xFFe0e0e0);

  // ============== Dark Theme Colors ==============
  static const Color darkPrimary = Color(0xFFa8c7fa);
  static const Color darkOnPrimary = Color(0xFF003258);
  static const Color darkPrimaryContainer = Color(0xFF00497d);
  static const Color darkOnPrimaryContainer = Color(0xFFd3e3fd);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkOnSurface = Color(0xFFe6e1e5);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Color(0xFFe6e1e5);
  static const Color darkSurfaceVariant = Color(0xFF49454f);
  static const Color darkOnSurfaceVariant = Color(0xFFcac4d0);

  // ============== Gradients ==============
  static const List<Color> primaryGradient = [
    Color(0xFF1a73e8),
    Color(0xFF4285f4),
  ];

  static const List<Color> successGradient = [
    Color(0xFF34a853),
    Color(0xFF4caf50),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFb00020),
    Color(0xFFd32f2f),
  ];

  // ============== Transparency Colors ==============
  static const Color primaryTransparent = Color(0x1F1a73e8);
  static const Color successTransparent = Color(0x1F34a853);
  static const Color errorTransparent = Color(0x1Fb00020);
  static const Color warningTransparent = Color(0x1Fff9800);

  // ============== Utility Methods ==============
  /// Returns appropriate color based on RFID sticker status
  static Color rfidStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return rfidActive;
      case 'expired':
        return rfidExpired;
      case 'revoked':
        return rfidRevoked;
      case 'lost':
        return rfidLost;
      default:
        return textSecondary;
    }
  }

  /// Returns appropriate color based on verification result
  static Color verificationColor(String result) {
    switch (result.toLowerCase()) {
      case 'granted':
        return accessGranted;
      case 'denied':
        return accessDenied;
      case 'pending':
        return accessPending;
      default:
        return textSecondary;
    }
  }

  /// Returns appropriate color based on priority level
  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return priorityLow;
      case 'medium':
        return priorityMedium;
      case 'high':
        return priorityHigh;
      case 'urgent':
        return priorityUrgent;
      default:
        return textSecondary;
    }
  }

  /// Returns appropriate color based on incident severity
  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return priorityLow;
      case 'medium':
        return priorityMedium;
      case 'high':
        return priorityHigh;
      case 'critical':
        return priorityUrgent;
      default:
        return textSecondary;
    }
  }
}