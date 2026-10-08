import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/app_locale_service.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../auth/app_mode.dart';
import '../../../auth/app_mode_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/scanner_auth_session_gateway.dart';
import '../../home/controllers/home_controller.dart';
import '../../partner/controllers/partner_controller.dart';
import '../../shell/controllers/shell_controller.dart';

class SettingsController extends GetxController {
  SettingsController(
    this._localeService,
    this._themeService,
    this._modeController,
    this._auth,
  );

  final AppLocaleService _localeService;
  final ThemeService _themeService;
  final AppModeController _modeController;
  final ScannerAuthSessionGateway _auth;

  Rx<Locale> get locale => _localeService.locale;
  Rx<ThemeMode> get themeMode => _themeService.themeMode;
  Rxn<AppMode> get activeMode => _modeController.activeMode;

  Future<void> setLanguage(String languageCode) =>
      _localeService.changeLanguage(languageCode);

  Future<void> setTheme(ThemeMode mode) => _themeService.setThemeMode(mode);

  AppMode get destinationMode => activeMode.value == AppMode.partner
      ? AppMode.scanner
      : AppMode.partner;

  Future<void> switchMode() async {
    final target = destinationMode;
    final hasStoredOfflineSession = await _auth.restoreMode(target);
    _disposeModeControllers();
    if (hasStoredOfflineSession) {
      await _modeController.markAuthenticated(target);
      Get.offAllNamed<void>(AppRoutes.shell);
      return;
    }
    Get.offAllNamed<void>(AppRoutes.login, arguments: target);
  }

  void _disposeModeControllers() {
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
    }
    if (Get.isRegistered<PartnerController>()) {
      Get.delete<PartnerController>(force: true);
    }
    if (Get.isRegistered<ShellController>()) {
      Get.delete<ShellController>(force: true);
    }
  }
}
