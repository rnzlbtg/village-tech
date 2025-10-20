import 'package:flutter/material.dart';

class AppTheme {
  // Forest Green Color Scheme
  static const Color primaryColor = Color(0xFF105640); // Rich Forest Green
  static const Color secondaryColor = Color(0xFF2D7D5C); // Lighter Green
  static const Color accentColor = Color(0xFFF59E0B); // Warm Amber
  static const Color errorColor = Color(0xFFDC2626); // Red
  static const Color warningColor = Color(0xFFEA580C); // Orange
  static const Color successColor = Color(0xFF059669); // Green

  // Light theme colors - optimized for forest green
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightOnBackground = Color(0xFF1F2937);

  // Dark theme colors - optimized for forest green
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A2332);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFF3F4F6);
  static const Color darkOnBackground = Color(0xFFF3F4F6);

  // Additional color variations for better UI flexibility
  static const Color primaryVariant = Color(0xFF0A402D);
  static const Color secondaryVariant = Color(0xFF1E5D45);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color outlineColor = Color(0xFFD1D5DB);
  static const Color outlineVariantColor = Color(0xFFE5E7EB);

  // Gradient colors for special elements
  static const List<Color> primaryGradient = [
    Color(0xFF105640),
    Color(0xFF2D7D5C),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFCD34D),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        onSurface: lightOnSurface,
        error: errorColor,
        onPrimary: lightOnPrimary,
        onSecondary: lightOnSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: lightOnPrimary,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: lightOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: lightOnSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: lightOnSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: lightOnSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: lightOnSurface,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        onSurface: darkOnSurface,
        error: errorColor,
        onPrimary: darkOnPrimary,
        onSecondary: darkOnSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: darkOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkOnSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
      ),
    );
  }

  // Status colors for different states - optimized for forest green theme
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'verified':
      case 'completed':
      case 'checked_in':
        return successColor;
      case 'pending':
      case 'in_progress':
        return warningColor;
      case 'expired':
      case 'disabled':
      case 'cancelled':
      case 'denied':
      case 'checked_out':
        return errorColor;
      default:
        return const Color(0xFF6B7280); // Neutral gray
    }
  }

  // Entry type colors - forest green theme optimized
  static Color getEntryTypeColor(String entryType) {
    switch (entryType.toLowerCase()) {
      case 'resident':
        return primaryColor; // Forest green
      case 'guest':
        return secondaryColor; // Lighter green
      case 'delivery':
        return accentColor; // Warm amber
      case 'construction':
        return const Color(0xFF7C3AED); // Purple
      case 'service':
        return const Color(0xFF0EA5E9); // Sky blue
      case 'emergency':
        return errorColor; // Red
      default:
        return const Color(0xFF6B7280); // Neutral gray
    }
  }

  // Severity colors for incidents - forest green theme optimized
  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return const Color(0xFF0EA5E9); // Sky blue
      case 'medium':
        return warningColor; // Orange
      case 'high':
        return const Color(0xFFEA580C); // Darker orange
      case 'critical':
        return errorColor; // Red
      default:
        return const Color(0xFF6B7280); // Neutral gray
    }
  }

  // Additional color helpers for forest green theme
  static Color getCardBackgroundColor(bool isDark) {
    return isDark ? darkSurface : lightSurface;
  }

  static Color getBorderColor(bool isDark) {
    return isDark ? const Color(0xFF374151) : outlineColor;
  }

  static Color getTextColor(bool isDark) {
    return isDark ? darkOnSurface : lightOnSurface;
  }

  // Get contrasting text color for backgrounds
  static Color getContrastColor(Color backgroundColor) {
    // Calculate luminance to determine text color
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF1F2937) : const Color(0xFFFFFFFF);
  }
}