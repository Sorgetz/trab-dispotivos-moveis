import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _useFirebaseKey = 'useFirebase';

  static Future<bool> isUsingFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useFirebaseKey) ?? false;
  }

  static Future<void> setUseFirebase(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useFirebaseKey, value);
  }
}
