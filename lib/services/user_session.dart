import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserSession {
  Future<void> setUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  // New methods for skip question functionality
  Future<void> setSkipQuestion(bool skip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skip_question', skip);
  }

  Future<bool> getSkipQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('skip_question') ?? false;
  }
}
