import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService extends GetxService {
  late final SharedPreferences _preferences;

  Future<LocalStorageService> init() async {
    _preferences = await SharedPreferences.getInstance();
    return this;
  }

  bool getBool(String key, {bool fallback = false}) =>
      _preferences.getBool(key) ?? fallback;

  String? getString(String key) => _preferences.getString(key);

  Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}

abstract final class StorageKeys {
  static const locale = 'app_locale';
  static const themeMode = 'theme_mode';
  static const onboardingSeen = 'scanner_partner_onboarding_seen';
}
