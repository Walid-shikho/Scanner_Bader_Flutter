import 'package:get/get.dart';

import '../../../auth/app_mode_controller.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController(this.modeController);
  final AppModeController modeController;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final mode = await modeController.bootstrap();
    Get.offAllNamed<void>(mode == null ? AppRoutes.login : AppRoutes.shell);
  }
}
