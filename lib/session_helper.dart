import 'package:shared_preferences/shared_preferences.dart';

class SessionHelper {
  static const String greetKey = "greeted_once";

  static Future<bool> hasGreeted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(greetKey) ?? false;
  }

  static Future<void> setGreeted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(greetKey, true);
  }

  static Future<void> resetGreet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(greetKey);
  }
}
