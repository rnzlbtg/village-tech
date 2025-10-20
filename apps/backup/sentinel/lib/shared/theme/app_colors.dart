import 'package:flutter/material.dart';

/// Application color palette following Material 3 design system
/// Sentinel App - Security and access control theme
class AppColors {
  AppColors._();

  // ============== Primary Colors ==============
  /// Primary forest green for main branding and actions
  static const Color primary = Color(0xFF105640);
  static const Color onPrimary = Color(0xFFffffff);
  static const Color primaryContainer = Color(0xFFE6F4F0);
  static const Color onPrimaryContainer = Color(0xFF0A3326);

  // ============== Secondary Colors ==============
  /// Secondary lighter green for complementary elements
  static const Color secondary = Color(0xFF2D7D5C);
  static const Color onSecondary = Color(0xFFffffff);
  static const Color secondaryContainer = Color(0xFFE8F5F1);
  static const Color onSecondaryContainer = Color(0xFF1A4A37);

  // ============== Tertiary Colors ==============
  /// Tertiary warm amber for highlights and calls to action
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color onTertiary = Color(0xFFffffff);
  static const Color tertiaryContainer = Color(0xFFFEF3C7);
  static const Color onTertiaryContainer = Color(0xFF7C2D12);

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
  static const Color success = Color(0xFF2D7D5C);
  static const Color successLight = Color(0xFFE8F5F1);
  static const Color onSuccess = Color(0xFFffffff);

  /// Error colors (access denied, invalid)
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFffffff);

  /// Warning colors (pending, attention needed)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFffffff);

  /// Info colors (information, neutral)
  static const Color info = Color(0xFF2196f3);
  static const Color infoLight = Color(0xFFe3f2fd);
  static const Color onInfo = Color(0xFFffffff);

  // ============== Security-Specific Colors ==============
  /// Access granted color (using secondary green)
  static const Color accessGranted = Color(0xFF2D7D5C);
  static const Color accessDenied = Color(0xFFDC2626);
  static const Color accessPending = Color(0xFFF59E0B);

  /// RFID status colors
  static const Color rfidActive = Color(0xFF2D7D5C);
  static const Color rfidExpired = Color(0xFFDC2626);
  static const Color rfidRevoked = Color(0xFF6B7280);
  static const Color rfidLost = Color(0xFFEA580C);

  /// Priority levels for incidents and announcements
  static const Color priorityLow = Color(0xFF2D7D5C);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFDC2626);
  static const Color priorityUrgent = Color(0xFF7C3AED);

  // ============== Border and Outline Colors ==============
  static const Color outline = Color(0xFF79747e);
  static const Color outlineVariant = Color(0xFFcac4d0);
  static const Color border = Color(0xFFe0e0e0);
  static const Color borderLight = Color(0xFFF5F5F5);
  static const Color darkOutline = Color(0xFF938f99);

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
    Color(0xFF105640),
    Color(0xFF2D7D5C),
  ];

  static const List<Color> successGradient = [
    Color(0xFF2D7D5C),
    Color(0xFF3E8F6E),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFDC2626),
    Color(0xFFEF4444),
  ];

  // ============== Transparency Colors ==============
  static const Color primaryTransparent = Color(0x1F105640);
  static const Color successTransparent = Color(0x1F2D7D5C);
  static const Color errorTransparent = Color(0x1FDC2626);
  static const Color warningTransparent = Color(0x1FF59E0B);

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