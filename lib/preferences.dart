// contains the functions used to fetch and store data with the Shared Preferences package.
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> readSavedPreference(String key) async {
  final preferences = await SharedPreferences.getInstance();
  final bool value = preferences.getBool(key) ?? false;
  return value;
}

Future<void> savePreference(String key, bool value) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setBool(key, value);
}
