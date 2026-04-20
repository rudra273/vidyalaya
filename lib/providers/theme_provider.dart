import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

/// Keys for SharedPreferences.
const _themeModeKey = 'theme_mode';

/// Notifier that manages the app's ThemeMode, persisted via SharedPreferences.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_themeModeKey);
    switch (stored) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    switch (mode) {
      case ThemeMode.dark:
        prefs.setString(_themeModeKey, 'dark');
      case ThemeMode.light:
        prefs.setString(_themeModeKey, 'light');
      case ThemeMode.system:
        prefs.remove(_themeModeKey);
    }
  }

  void toggle() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
