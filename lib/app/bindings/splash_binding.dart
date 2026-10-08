import 'package:get/get.dart';

import '../auth/app_mode_controller.dart';
import '../modules/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(
        Get.find<AppModeController>(),
      ),
    );
  }
}