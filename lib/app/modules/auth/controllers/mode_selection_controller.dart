import 'package:get/get.dart';

import '../../../auth/app_mode.dart';
import '../../../auth/app_mode_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/scanner_auth_session_gateway.dart';

class ModeSelectionController extends GetxController {
  ModeSelectionController(this.auth, this.modeController);

  final ScannerAuthSessionGateway auth;
  final AppModeController modeController;

  Future<void> choose(AppMode mode) async {
    if (await auth.restoreMode(mode)) {
      await modeController.markAuthenticated(mode);
      Get.offAllNamed<void>(AppRoutes.shell);
      return;
    }
    Get.toNamed<void>(AppRoutes.login, arguments: mode);
  }
}
