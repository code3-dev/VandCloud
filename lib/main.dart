import 'package:flutter/material.dart';
import 'package:vandcloud/services/theme_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTheme _currentTheme = AppTheme.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load theme preference when app starts
  Future<void> _loadThemePreference() async {
    final theme = await ThemeService.loadThemePreference();
    setState(() {
      _currentTheme = theme;
    });
  }

  // Update theme when user selects a new one
  void _updateTheme(AppTheme newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VandCloud',
      theme: ThemeService.getThemeData(_currentTheme),
      home: HomeScreen(onThemeChanged: _updateTheme),
    );
  }
}
