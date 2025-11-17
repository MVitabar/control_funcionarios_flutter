import 'package:flutter/material.dart';

class AppTheme {
  // Professional color palette
  static const Color primaryColorLight = Color(0xFF2563EB);    // Blue-600
  static const Color primaryColorDark = Color(0xFF3B82F6);     // Blue-500
  static const Color dangerColor = Color(0xFFEF4444);          // Red-500
  static const Color successColor = Color(0xFF10B981);         // Green-500
  static const Color warningColor = Color(0xFFF59E0B);         // Amber-500

  static const Color tintColorLight = primaryColorLight;
  static const Color tintColorDark = Color(0xFFEFF6FF);        // Light blue-50

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColorLight,
      secondary: Color(0xFF64748B), // Slate-500
      surface: Color(0xFFFFFFFF), // White
      error: dangerColor,
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1F2937), // Gray-800
      onError: Color(0xFFFFFFFF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF1F2937),
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorLight,
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        shadowColor: primaryColorLight.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)), // Gray-300
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)), // Gray-300
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColorLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dangerColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: primaryColorLight,
      unselectedItemColor: Color(0xFF9CA3AF), // Gray-400
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColorDark,
      secondary: Color(0xFF64748B), // Slate-500
      surface: Color(0xFF1F2937), // Gray-800
      error: dangerColor,
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFFF3F4F6), // Gray-100
      onError: Color(0xFFFFFFFF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2937),
      foregroundColor: Color(0xFFF3F4F6),
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1F2937),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorDark,
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        shadowColor: primaryColorDark.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F2937),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4B5563)), // Gray-600
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4B5563)), // Gray-600
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColorDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dangerColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1F2937),
      selectedItemColor: tintColorDark,
      unselectedItemColor: Color(0xFF6B7280), // Gray-500
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // Helper methods for getting colors based on theme
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSuccessColor(BuildContext context) {
    return successColor;
  }

  static Color getWarningColor(BuildContext context) {
    return warningColor;
  }

  static Color getDangerColor(BuildContext context) {
    return dangerColor;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getOnSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
}
