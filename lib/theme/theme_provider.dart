import 'package:flutter/material.dart';
import 'package:monlamai_app/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(lightMode);

  void toggleTheme(bool isDark) {
    state = isDark ? darkMode : lightMode;
  }

  ThemeData get themeData => state;

  bool get isDarkMode => state == darkMode;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});
