import 'package:get/get.dart';

import '../auth/app_mode_controller.dart';
import '../modules/auth/controllers/login_controller.dart';
import '../modules/auth/controllers/mode_selection_controller.dart';
import '../services/prelogin_identifier_provider.dart';
import '../services/scanner_auth_session_gateway.dart';

class ModeSelectionBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ModeSelectionController>(
        () => ModeSelectionController(
          Get.find<ScannerAuthSessionGateway>(),
          Get.find<AppModeController>(),
        ),
      );
}

class LoginBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<LoginController>(
        () => LoginController(
          Get.find<ScannerAuthSessionGateway>(),
          Get.find<AppModeController>(),
          Get.isRegistered<PreLoginIdentifierProvider>()
              ? Get.find<PreLoginIdentifierProvider>()
              : null,
        ),
      );
}
