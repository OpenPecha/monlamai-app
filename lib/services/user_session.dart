import 'package:flutter/material.dart';
import 'package:monlamai_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserSession {
  Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    var userStored = await prefs.setString('user', user.toJson());
    debugPrint('User Stored: $userStored and ${user.toJson()}');
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final userDataMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userDataMap);
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    bool isRemoved = await prefs.remove('user');
    debugPrint('User Removed: $isRemoved');
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
