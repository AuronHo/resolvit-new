import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  // Default to system setting or Light
  ThemeMode _themeMode = ThemeMode.system; 

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}