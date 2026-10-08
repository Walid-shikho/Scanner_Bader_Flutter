import 'package:get/get.dart';

import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/partner_manager_repository.dart';

class PartnerController extends GetxController {
  PartnerController(this.repository);

  final PartnerManagerRepository repository;
  final profile = Rxn<PartnerDetail>();

  @override
  void onInit() {
    super.onInit();
    _loadProfileHeader();
  }

  Future<void> _loadProfileHeader() async {
    try {
      profile.value = await repository.getPartnerProfile();
    } catch (_) {
      // Home remains fully usable if the optional greeting lookup fails.
    }
  }

  void openSettings() => Get.toNamed<void>(AppRoutes.settings);
  void openPartnerProfile() => Get.toNamed<void>(AppRoutes.partnerProfile);
  void openBranches() => Get.toNamed<void>(AppRoutes.partnerBranches);
  void openMemberships() => Get.toNamed<void>(AppRoutes.memberships);
  void openOffers() => Get.toNamed<void>(AppRoutes.partnerOffers);
  void openNotifications() => Get.toNamed<void>(AppRoutes.partnerNotifications);
}
