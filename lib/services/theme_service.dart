import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum to represent available themes
enum AppTheme { system, light, dark }

class ThemeService {
  static const String _themeKey = 'selected_theme';

  // Convert theme enum to string for storage
  static String _themeToString(AppTheme theme) {
    switch (theme) {
      case AppTheme.system:
        return 'system';
      case AppTheme.light:
        return 'light';
      case AppTheme.dark:
        return 'dark';
    }
  }

  // Convert string to theme enum
  static AppTheme _stringToTheme(String themeString) {
    switch (themeString) {
      case 'light':
        return AppTheme.light;
      case 'dark':
        return AppTheme.dark;
      case 'system':
      default:
        return AppTheme.system;
    }
  }

  // Save theme preference to shared preferences
  static Future<void> saveThemePreference(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeToString(theme));
  }

  // Load theme preference from shared preferences
  static Future<AppTheme> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);
    if (themeString != null) {
      return _stringToTheme(themeString);
    }
    return AppTheme.system; // Default to system theme
  }

  // Get theme data based on selected theme and system brightness
  static ThemeData getThemeData(
    AppTheme theme, {
    Brightness? systemBrightness,
  }) {
    switch (theme) {
      case AppTheme.light:
        return _buildLightTheme();
      case AppTheme.dark:
        return _buildDarkTheme();
      case AppTheme.system:
      default:
        // Use system brightness to determine theme
        final brightness = systemBrightness ?? Brightness.light;
        return brightness == Brightness.dark
            ? _buildDarkTheme()
            : _buildLightTheme();
    }
  }

  // Light theme definition
  static ThemeData _buildLightTheme() {
    return ThemeData.light(useMaterial3: true).copyWith(
      primaryColor: Color(0xFF4A6FFF),
      scaffoldBackgroundColor: Color(0xFFF8F9FA),
      cardColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF4A6FFF),
        secondary: Color(0xFF6C63FF),
        surface: Colors.white,
        background: Color(0xFFF8F9FA),
      ),
    );
  }

  // Dark theme definition
  static ThemeData _buildDarkTheme() {
    return ThemeData.dark(useMaterial3: true).copyWith(
      primaryColor: Color(0xFF6C63FF),
      scaffoldBackgroundColor: Color(0xFF1A1A2E),
      cardColor: Color(0xFF2D2D3A),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF4A6FFF),
        surface: Color(0xFF2D2D3A),
        background: Color(0xFF1A1A2E),
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
    );
  }
}
