import 'package:get/get.dart';

import '../../../auth/app_mode.dart';
import '../../../auth/app_mode_controller.dart';
import '../../home/controllers/home_controller.dart';

class ShellController extends GetxController {
  ShellController(this.modeController);

  final AppModeController modeController;

  AppMode? get activeMode => modeController.activeMode.value;

  void openScanFoundation() {
    if (activeMode != AppMode.scanner) return;
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().openScan();
    }
  }
}
