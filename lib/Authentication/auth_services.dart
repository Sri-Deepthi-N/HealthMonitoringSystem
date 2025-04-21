import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_management/Screens/login.dart';


class AuthService {
  Future<void> saveUserLogin(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setString('UserName', username);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user_id') && prefs.containsKey('UserName')) {
      return {
        'user_id': prefs.getInt('user_id'),
        'UserName': prefs.getString('UserName'),
      };
    }
    return null;
  }

  Future<void> signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );  }

}