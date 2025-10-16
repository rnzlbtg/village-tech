import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Application text styles following Material 3 design system
/// Sentinel App - Security and access control typography
class AppTextStyles {
  AppTextStyles._();

  // ============== Display Styles ==============
  static TextStyle get displayLarge => TextStyle(
    fontSize: 57.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: 45.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle get displaySmall => TextStyle(
    fontSize: 36.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // ============== Headline Styles ==============
  static TextStyle get headlineLarge => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );

  // ============== Title Styles ==============
  static TextStyle get titleLarge => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle get titleMedium => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static TextStyle get titleSmall => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ============== Body Styles ==============
  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ============== Label Styles ==============
  static TextStyle get labelLarge => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get labelMedium => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle get labelSmall => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ============== Custom Sentinel App Styles ==============

  // Screen Headers
  static TextStyle get screenTitle => titleLarge.copyWith(
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1c1b1f),
  );

  static TextStyle get screenSubtitle => bodyMedium.copyWith(
    color: const Color(0xFF49454f),
  );

  // Security Status Messages
  static TextStyle get accessGranted => titleMedium.copyWith(
    fontWeight: FontWeight.w600,
    color: const Color(0xFF00c853),
  );

  static TextStyle get accessDenied => titleMedium.copyWith(
    fontWeight: FontWeight.w600,
    color: const Color(0xFFd50000),
  );

  static TextStyle get accessPending => titleMedium.copyWith(
    fontWeight: FontWeight.w600,
    color: const Color(0xFFffab00),
  );

  // Card Titles
  static TextStyle get cardTitle => titleMedium.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get cardSubtitle => bodyMedium.copyWith(
    color: const Color(0xFF49454f),
  );

  // Button Text
  static TextStyle get buttonText => labelLarge.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get buttonTextLarge => titleSmall.copyWith(
    fontWeight: FontWeight.w600,
  );

  // Form Input
  static TextStyle get inputLabel => bodyLarge.copyWith(
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1c1b1f),
  );

  static TextStyle get inputHint => bodyLarge.copyWith(
    color: const Color(0xFF938f99),
  );

  static TextStyle get inputText => bodyLarge.copyWith(
    color: const Color(0xFF1c1b1f),
  );

  // Status Labels
  static TextStyle get statusLabel => bodySmall.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get statusActive => statusLabel.copyWith(
    color: const Color(0xFF00c853),
  );

  static TextStyle get statusInactive => statusLabel.copyWith(
    color: const Color(0xFF9e9e9e),
  );

  static TextStyle get statusError => statusLabel.copyWith(
    color: const Color(0xFFd50000),
  );

  // Navigation
  static TextStyle get navLabel => labelSmall.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get navLabelActive => navLabel.copyWith(
    color: const Color(0xFF1a73e8),
  );

  static TextStyle get navLabelInactive => navLabel.copyWith(
    color: const Color(0xFF757575),
  );

  // RFID Specific
  static TextStyle get rfidCode => bodyLarge.copyWith(
    fontFamily: 'monospace',
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  static TextStyle get rfidStatus => bodySmall.copyWith(
    fontWeight: FontWeight.w500,
  );

  // Timer and Duration
  static TextStyle get timerDisplay => displayLarge.copyWith(
    fontFamily: 'monospace',
    fontWeight: FontWeight.w300,
    color: const Color(0xFF1a73e8),
  );

  static TextStyle get durationLabel => bodySmall.copyWith(
    color: const Color(0xFF49454f),
  );

  // Lists and Tables
  static TextStyle get listItemTitle => bodyLarge.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get listItemSubtitle => bodySmall.copyWith(
    color: const Color(0xFF49454f),
  );

  static TextStyle get listHeader => titleSmall.copyWith(
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1c1b1f),
  );

  // Error and Validation Messages
  static TextStyle get errorMessage => bodySmall.copyWith(
    color: const Color(0xFFd50000),
  );

  static TextStyle get warningMessage => bodySmall.copyWith(
    color: const Color(0xFFff9800),
  );

  static TextStyle get infoMessage => bodySmall.copyWith(
    color: const Color(0xFF2196f3),
  );

  // Empty States
  static TextStyle get emptyStateTitle => titleLarge.copyWith(
    color: const Color(0xFF49454f),
  );

  static TextStyle get emptyStateMessage => bodyMedium.copyWith(
    color: const Color(0xFF757575),
  );

  // Loading and Progress
  static TextStyle get loadingMessage => bodyMedium.copyWith(
    color: const Color(0xFF49454f),
  );

  // Badges and Tags
  static TextStyle get badge => labelSmall.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get badgePrimary => badge.copyWith(
    color: const Color(0xFFffffff),
  );

  static TextStyle get badgeSecondary => badge.copyWith(
    color: const Color(0xFF1a73e8),
  );

  // Chip Labels
  static TextStyle get chipLabel => bodySmall.copyWith(
    fontWeight: FontWeight.w500,
  );

  // Priority and Severity
  static TextStyle get priorityLow => chipLabel.copyWith(
    color: const Color(0xFF00c853),
  );

  static TextStyle get priorityMedium => chipLabel.copyWith(
    color: const Color(0xFFff9800),
  );

  static TextStyle get priorityHigh => chipLabel.copyWith(
    color: const Color(0xFFd50000),
  );

  static TextStyle get priorityUrgent => chipLabel.copyWith(
    color: const Color(0xFF9c27b0),
    fontWeight: FontWeight.w600,
  );

  // Timestamps and Dates
  static TextStyle get timestamp => bodySmall.copyWith(
    color: const Color(0xFF757575),
    fontFamily: 'monospace',
  );

  static TextStyle get dateLabel => bodySmall.copyWith(
    color: const Color(0xFF49454f),
  );

  // Search and Filters
  static TextStyle get searchHint => bodyLarge.copyWith(
    color: const Color(0xFF938f99),
  );

  static TextStyle get filterLabel => bodySmall.copyWith(
    fontWeight: FontWeight.w500,
    color: const Color(0xFF49454f),
  );

  // ============== Utility Methods ==============

  /// Returns text style for RFID status
  static TextStyle rfidStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return statusActive;
      case 'expired':
        return statusError;
      case 'revoked':
        return statusInactive;
      case 'lost':
        return statusError;
      default:
        return statusLabel;
    }
  }

  /// Returns text style for verification result
  static TextStyle verificationStyle(String result) {
    switch (result.toLowerCase()) {
      case 'granted':
        return accessGranted;
      case 'denied':
        return accessDenied;
      case 'pending':
        return accessPending;
      default:
        return statusLabel;
    }
  }

  /// Returns text style for priority level
  static TextStyle priorityStyle(String priority) {
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
        return chipLabel;
    }
  }

  /// Returns text style for incident severity
  static TextStyle severityStyle(String severity) {
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
        return chipLabel;
    }
  }

  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply size to text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}