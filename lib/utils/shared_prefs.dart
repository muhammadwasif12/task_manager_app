import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesUtils {
  static Future<void> saveStringList(String key, List<String> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(list));
  }

  static Future<List<String>> getStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.cast<String>();
  }

  static Future<void> saveTasks(String key, List<Map<String, dynamic>> tasks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(tasks));
  }

  static Future<List<Map<String, dynamic>>> getTasks(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTasks = prefs.getString(key);
    if (savedTasks == null) return [];
    List<dynamic> jsonResponse = json.decode(savedTasks);
    return jsonResponse.cast<Map<String, dynamic>>();
  }

  static Future<void> clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
