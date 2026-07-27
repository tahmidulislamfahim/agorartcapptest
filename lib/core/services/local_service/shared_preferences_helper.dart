import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyAccessToken = 'access_token';
  static const String _keyUserData = 'user_data';

  static Future<bool> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyAccessToken, token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<bool> removeAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyAccessToken);
  }

  static Future<bool> saveUser(Map<String, dynamic> userMap) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserData, jsonEncode(userMap));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userStr = prefs.getString(_keyUserData);
    if (userStr != null) {
      try {
        return jsonDecode(userStr) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
