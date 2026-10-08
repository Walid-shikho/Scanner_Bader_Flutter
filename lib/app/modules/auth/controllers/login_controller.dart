import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../auth/app_mode.dart';
import '../../../auth/app_mode_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/offline_auth_session_gateway.dart';
import '../../../services/prelogin_identifier_provider.dart';
import '../../../services/scanner_auth_session_gateway.dart';
import '../../../services/scanner_partner_repository.dart';

class LoginController extends GetxController {
  LoginController(this.auth, this.modeController, this.identifiers);

  final ScannerAuthSessionGateway auth;
  final AppModeController modeController;
  final PreLoginIdentifierProvider? identifiers;

  final selectedMode = AppMode.partner.obs;
  final email = TextEditingController(text: 'demo@bader.local');
  final password = TextEditingController(text: 'demo');
  final loading = false.obs;
  final errorKey = RxnString();
  final obscurePassword = true.obs;

  AppMode get mode => selectedMode.value;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is AppMode) selectedMode.value = argument;
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }

  void selectMode(AppMode mode) {
    if (loading.value || selectedMode.value == mode) return;
    selectedMode.value = mode;
    errorKey.value = null;
  }

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> submit() async {
    if (loading.value) return;
    errorKey.value = null;
    loading.value = true;
    final targetMode = selectedMode.value;
    try {
      if (AppConfig.isOfflineDemo && auth is OfflineAuthSessionGateway) {
        await (auth as OfflineAuthSessionGateway).loginOffline(
          mode: targetMode,
          email: email.text.trim(),
          password: password.text,
        );
      } else if (targetMode == AppMode.partner) {
        final ids = await identifiers?.partnerIdentifiers();
        if (ids == null) {
          throw const ScannerContractGapException(
            'identifier_provisioning_unavailable',
          );
        }
        await auth.loginPartner(
          PartnerLoginRequest(
            email: email.text.trim(),
            password: password.text,
            partnerPublicId: ids.partnerPublicId,
            devicePublicId: ids.devicePublicId,
          ),
        );
      } else {
        final ids = await identifiers?.scannerIdentifiers();
        if (ids == null) {
          throw const ScannerContractGapException(
            'identifier_provisioning_unavailable',
          );
        }
        await auth.loginScanner(
          ScannerLoginRequest(
            email: email.text.trim(),
            password: password.text,
            scannerDevicePublicId: ids.scannerDevicePublicId,
            branchPublicId: ids.branchPublicId,
          ),
        );
      }
      await modeController.markAuthenticated(targetMode);
      Get.offAllNamed<void>(AppRoutes.shell);
    } on FormatException catch (_) {
      errorKey.value = 'offline_demo_login_invalid';
    } on ScannerContractGapException catch (_) {
      errorKey.value = 'identifier_provisioning_unavailable';
    } catch (_) {
      errorKey.value = 'login_failed';
    } finally {
      loading.value = false;
    }
  }
}
