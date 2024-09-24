import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monlamai_app/providers/shared_preferences_provider.dart';
import 'package:monlamai_app/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for isDarkMode
final isDarkModeProvider =
    StateNotifierProvider<IsDarkModeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return IsDarkModeNotifier(prefs);
});

class IsDarkModeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const String _key = 'isDarkMode';

  IsDarkModeNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    state = _prefs.getBool(_key) ?? false;
  }

  void toggle() {
    state = !state;
    _prefs.setBool(_key, state);
  }

  void setDarkMode(bool isDark) {
    state = isDark;
    _prefs.setBool(_key, isDark);
  }
}
