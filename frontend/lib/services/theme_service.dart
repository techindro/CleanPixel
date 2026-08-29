import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _prefKey = 'cleanpixel_theme_mode';
  // Default to pure White & Pink theme
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_prefKey) ?? 'light';
    if (savedTheme == 'dark') {
      themeModeNotifier.value = ThemeMode.dark;
    } else if (savedTheme == 'system') {
      themeModeNotifier.value = ThemeMode.system;
    } else {
      themeModeNotifier.value = ThemeMode.light;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String str = 'light';
    if (mode == ThemeMode.dark) str = 'dark';
    if (mode == ThemeMode.system) str = 'system';
    await prefs.setString(_prefKey, str);
    themeModeNotifier.value = mode;
  }

  static String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark Mode (OLED)';
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
      default:
        return 'Light Mode (White & Pink)';
    }
  }
}
