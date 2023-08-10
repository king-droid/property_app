import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  /// Read string value
  static Future<String> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = await prefs.getString(key);
    return value ?? "";
  }


  static Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  /// Read boolean value
  static Future<bool> getBoolean(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = await prefs.getBool(key);
    return value ?? false;
  }

  /// Save boolean value
  static Future<void> setBoolean(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Delete saved value using key
  static Future<void> deleteValue(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
