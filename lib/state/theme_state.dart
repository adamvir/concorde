import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ThemeMode {
  light,
  dark,
  system,
}

// Theme State - Singleton pattern for theme management
class ThemeState extends ChangeNotifier {
  static final ThemeState _instance = ThemeState._internal();
  factory ThemeState() => _instance;

  ThemeState._internal() {
    // Initialize with system theme
    _mode = ThemeMode.system;
    _updateEffectiveTheme();
  }

  ThemeMode _mode = ThemeMode.system;
  bool _effectiveIsDark = false;

  ThemeMode get mode => _mode;
  bool get isDark => _effectiveIsDark;

  // Update the effective theme based on mode and system settings
  void _updateEffectiveTheme() {
    if (_mode == ThemeMode.system) {
      // Get system brightness
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      _effectiveIsDark = brightness == Brightness.dark;
    } else {
      _effectiveIsDark = _mode == ThemeMode.dark;
    }
  }

  // Set theme mode
  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    _updateEffectiveTheme();
    notifyListeners();
  }

  // Toggle between light and dark (for quick toggle)
  void toggleTheme() {
    if (_mode == ThemeMode.system) {
      _mode = ThemeMode.light;
    } else if (_mode == ThemeMode.light) {
      _mode = ThemeMode.dark;
    } else {
      _mode = ThemeMode.light;
    }
    _updateEffectiveTheme();
    notifyListeners();
  }

  // Get theme mode label for UI
  String getThemeModeLabel() {
    switch (_mode) {
      case ThemeMode.light:
        return 'Világos';
      case ThemeMode.dark:
        return 'Sötét';
      case ThemeMode.system:
        return 'Automatikus';
    }
  }
}
