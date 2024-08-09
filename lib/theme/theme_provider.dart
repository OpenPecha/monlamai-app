import 'package:flutter/material.dart';
import 'package:monlamai_app/theme/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeData = isDark ? darkMode : lightMode; // Use _themeData
    notifyListeners(); // Call notifyListeners here
  }

  bool get isDarkMode => _themeData == darkMode;
}
