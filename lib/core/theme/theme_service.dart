import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../storage/local_storage_service.dart';

/// Manages the app-wide theme mode (light / dark / system).
///
/// Reads the persisted preference on init and exposes a reactive
/// [themeMode] that the root widget observes. Changes are written
/// to [LocalStorageService] so they survive app restarts.
class ThemeService extends GetxService {
  ThemeService(this._storage);

  final LocalStorageService _storage;

  final themeMode = ThemeMode.system.obs;

  Future<ThemeService> init() async {
    final stored = _storage.getString(StorageKeys.themeMode);
    themeMode.value = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return this;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final key = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.setString(StorageKeys.themeMode, key);
    Get.changeThemeMode(mode);
  }
}
