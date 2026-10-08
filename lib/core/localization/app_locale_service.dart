import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../storage/local_storage_service.dart';

class AppLocaleService extends GetxService {
  AppLocaleService(this._storage);

  final LocalStorageService _storage;
  int _changeEpoch = 0;

  static const supported = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('de'),
  ];

  final locale = const Locale('ar').obs;

  Future<AppLocaleService> init() async {
    final saved = _storage.getString(StorageKeys.locale);
    final languageCode = supported.any((item) => item.languageCode == saved)
        ? saved!
        : 'ar';
    locale.value = Locale(languageCode);
    return this;
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!supported.any((item) => item.languageCode == languageCode)) return;
    if (locale.value.languageCode == languageCode &&
        Get.locale?.languageCode == languageCode) {
      return;
    }

    final epoch = ++_changeEpoch;
    final next = Locale(languageCode);

    // Update GetX localization first so any model fields that still use `.tr`
    // while reparsing localized API data see the same language as the request.
    await Get.updateLocale(next);

    // A slower, older locale change must never become the source of truth.
    if (epoch != _changeEpoch) {
      final latest = locale.value;
      if (Get.locale?.languageCode != latest.languageCode) {
        await Get.updateLocale(latest);
      }
      return;
    }

    // AppLocaleService.locale remains the canonical observable used by
    // Accept-Language and feature-specific locale workers.
    locale.value = next;
    await _storage.setString(StorageKeys.locale, languageCode);
  }
}
