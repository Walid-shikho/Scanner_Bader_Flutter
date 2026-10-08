import 'package:flutter/widgets.dart';

/// Bader's locale-aware font families.
///
/// Font selection stays centralized here. UI widgets should inherit the
/// resolved family from the app theme rather than selecting a family directly.
abstract final class AppFonts {
  static const String arabic = 'Tajawal';
  static const String latin = 'Manrope';

  static String forLocale(Locale locale) {
    switch (locale.languageCode.toLowerCase()) {
      case 'ar':
        return arabic;
      case 'de':
      case 'en':
      default:
        return latin;
    }
  }
}
