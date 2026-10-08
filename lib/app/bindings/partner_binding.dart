import 'package:get/get.dart';

import '../modules/partner/controllers/partner_controller.dart';
import '../services/partner_manager_repository.dart';

class PartnerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PartnerController>()) {
      Get.lazyPut<PartnerController>(
        () => PartnerController(Get.find<PartnerManagerRepository>()),
      );
    }
  }
}
