import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/core/config/app_config.dart';
import 'package:scanner_partner/core/localization/app_locale_service.dart';
import 'package:scanner_partner/core/translations/app_translations.dart';

void main() {
  test('Scanner Partner settings expose only the supported product locales', () {
    expect(
      AppLocaleService.supported.map((locale) => locale.languageCode).toList(),
      <String>['ar', 'en', 'de'],
    );
  });

  test('Phase 12 settings translation keys exist in ar/en/de', () {
    final keys = AppTranslations().keys;
    const requiredKeys = <String>{
      'settings',
      'appearance',
      'theme_mode',
      'theme_system',
      'theme_light',
      'theme_dark',
      'language',
      'app_information',
      'bader_product_family',
      'scanner_partner_product',
      'app_version',
    };

    for (final locale in <String>['ar', 'en', 'de']) {
      final translations = keys[locale]!;
      for (final key in requiredKeys) {
        expect(
          translations[key],
          isNotNull,
          reason: '$key must exist for locale $locale',
        );
        expect(
          translations[key]!.trim(),
          isNotEmpty,
          reason: '$key must not be blank for locale $locale',
        );
      }
    }
  });

  test('App information remains Scanner Partner identity', () {
    expect(AppConfig.appType, 'partner');
    expect(AppConfig.appVersion, isNotEmpty);
  });
}
