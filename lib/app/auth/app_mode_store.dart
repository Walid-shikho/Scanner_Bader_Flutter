import 'package:shared_preferences/shared_preferences.dart';

import 'app_mode.dart';

abstract interface class AppModeStore {
  Future<AppMode?> readActiveMode();
  Future<void> writeActiveMode(AppMode mode);
  Future<void> clearActiveMode();
}

class SharedPreferencesAppModeStore implements AppModeStore {
  static const _key = 'active_mode';

  @override
  Future<AppMode?> readActiveMode() async {
    final preferences = await SharedPreferences.getInstance();
    return AppMode.tryParse(preferences.getString(_key));
  }

  @override
  Future<void> writeActiveMode(AppMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, mode.appCode);
  }

  @override
  Future<void> clearActiveMode() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
