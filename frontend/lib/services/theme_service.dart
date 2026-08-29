import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _prefKey = 'cleanpixel_theme_mode';
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_prefKey) ?? 'dark';
    if (savedTheme == 'light') {
      themeModeNotifier.value = ThemeMode.light;
    } else if (savedTheme == 'system') {
      themeModeNotifier.value = ThemeMode.system;
    } else {
      themeModeNotifier.value = ThemeMode.dark;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String str = 'dark';
    if (mode == ThemeMode.light) str = 'light';
    if (mode == ThemeMode.system) str = 'system';
    await prefs.setString(_prefKey, str);
    themeModeNotifier.value = mode;
  }

  static String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.dark:
      default:
        return 'Dark Mode (OLED)';
    }
  }
}
