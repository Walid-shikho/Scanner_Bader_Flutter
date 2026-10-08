import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/partner_manager_repository.dart';

enum PartnerProfileState { loading, loaded, permissionDenied, error }

class PartnerProfileController extends GetxController {
  PartnerProfileController(this.repository);

  final PartnerManagerRepository repository;

  final state = PartnerProfileState.loading.obs;
  final partner = Rxn<PartnerDetail>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = PartnerProfileState.loading;
    try {
      partner.value = await repository.getPartnerProfile();
      state.value = PartnerProfileState.loaded;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? PartnerProfileState.permissionDenied
          : PartnerProfileState.error;
    } catch (_) {
      state.value = PartnerProfileState.error;
    }
  }

  void openChangeRequest() {
    Get.toNamed<void>(AppRoutes.partnerProfileChange);
  }

  Future<void> openOperationalEdit() async {
    final result =
        await Get.toNamed<dynamic>(AppRoutes.partnerProfileOperationalEdit);
    if (result == true) await load();
  }

  void openBranches() => Get.toNamed<void>(AppRoutes.partnerBranches);

  void openMemberships() => Get.toNamed<void>(AppRoutes.memberships);

  void openOffers() => Get.toNamed<void>(AppRoutes.partnerOffers);

  void openSettings() => Get.toNamed<void>(AppRoutes.settings);
}
