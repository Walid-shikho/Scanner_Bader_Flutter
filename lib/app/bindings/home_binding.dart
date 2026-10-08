import 'package:get/get.dart';

import '../modules/home/controllers/home_controller.dart';
import '../services/scanner_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(Get.find<ScannerRepository>()),
      );
    }
  }
}
