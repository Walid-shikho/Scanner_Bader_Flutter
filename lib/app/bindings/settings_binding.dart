import 'package:get/get.dart';

import '../../core/localization/app_locale_service.dart';
import '../../core/theme/theme_service.dart';
import '../auth/app_mode.dart';
import '../auth/app_mode_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/settings/controllers/settings_controller.dart';
import '../services/scanner_auth_session_gateway.dart';
import '../services/scanner_repository.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    final modeController = Get.find<AppModeController>();

    if (modeController.activeMode.value == AppMode.scanner &&
        !Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(Get.find<ScannerRepository>()),
      );
    }

    Get.lazyPut<SettingsController>(
      () => SettingsController(
        Get.find<AppLocaleService>(),
        Get.find<ThemeService>(),
        modeController,
        Get.find<ScannerAuthSessionGateway>(),
      ),
    );
  }
}
