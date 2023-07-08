import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static SharedPreferences? _preferences;

  static const _keyTasks = "arrTasks";
  static const _keyCheckState = "arrCheckState";

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setTasks(List<String> value) async =>
      await _preferences!.setStringList(_keyTasks, value);

  static Future setCheckState(List<String> value) async =>
      await _preferences!.setStringList(_keyCheckState, value);

  static List<String>? getTasks() => _preferences!.getStringList(_keyTasks);
  static List<String>? getCheckState() =>
      _preferences!.getStringList(_keyCheckState);
}
