import 'package:get/get.dart';

import '../auth/app_mode.dart';
import '../auth/app_mode_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/partner/controllers/partner_controller.dart';
import '../modules/shell/controllers/shell_controller.dart';
import '../services/partner_manager_repository.dart';
import '../services/scanner_repository.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    final modeController = Get.find<AppModeController>();
    final mode = modeController.activeMode.value;
    if (mode == AppMode.scanner && !Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController(Get.find<ScannerRepository>()));
    }
    if (mode == AppMode.partner && !Get.isRegistered<PartnerController>()) {
      Get.lazyPut<PartnerController>(
        () => PartnerController(Get.find<PartnerManagerRepository>()),
      );
    }
    Get.lazyPut<ShellController>(() => ShellController(modeController));
  }
}
