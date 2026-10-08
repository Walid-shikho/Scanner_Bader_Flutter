import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/core/config/app_config.dart';
import 'package:scanner_partner/core/config/app_environment.dart';

void main() {
  test('physical application identity remains partner', () {
    expect(AppConfig.appType, 'partner');
  });

  test('Phase 15 delivered runtime is explicitly offline demo', () {
    expect(AppConfig.environment, AppEnvironment.offlineDemo);
    expect(AppConfig.isOfflineDemo, isTrue);
  });

  test('API base URL remains versioned for preserved production wiring', () {
    expect(AppConfig.apiBaseUrl.endsWith('/api/v1'), isTrue);
  });
}
