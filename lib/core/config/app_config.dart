import 'app_environment.dart';
import 'package:flutter/foundation.dart';

abstract final class AppConfig {

  /// Phase 15 delivered runtime. Production wiring remains available in main.dart
  /// but is deliberately inactive while this value is offlineDemo.
  static const environment = AppEnvironment.offlineDemo;
  static const bool isOfflineDemo = environment == AppEnvironment.offlineDemo;
  static const apiOrigin = String.fromEnvironment(
    'BADER_API_BASE_URL',
    defaultValue: 'https://api.example.invalid',
  );

  static String get apiBaseUrl {
    final normalized = apiOrigin.endsWith('/')
        ? apiOrigin.substring(0, apiOrigin.length - 1)
        : apiOrigin;
    return normalized.endsWith('/api/v1')
        ? normalized
        : '$normalized/api/v1';
  }

  static const appVersion = String.fromEnvironment(
    'BADER_APP_VERSION',
    defaultValue: '1.0.0',
  );

  static const timezone = String.fromEnvironment(
    'BADER_TIMEZONE',
    defaultValue: 'Asia/Damascus',
  );

  static String get platform {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      _ => 'android',
    };
  }

  // One physical mobile package hosts both logical modes.
  static const appType = 'partner';
}
