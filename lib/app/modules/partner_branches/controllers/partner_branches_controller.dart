import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/partner_manager_repository.dart';

enum PartnerBranchesState { loading, loaded, permissionDenied, error }

class PartnerBranchesController extends GetxController {
  PartnerBranchesController(this.repository);

  final PartnerManagerRepository repository;

  final state = PartnerBranchesState.loading.obs;
  final branches = <PartnerBranchData>[].obs;
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = PartnerBranchesState.loading;
    try {
      final result = await repository.getPartnerBranches();
      branches.assignAll(result.items);
      state.value = PartnerBranchesState.loaded;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? PartnerBranchesState.permissionDenied
          : PartnerBranchesState.error;
    } catch (_) {
      state.value = PartnerBranchesState.error;
    }
  }

  Future<void> refreshBranches() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      final result = await repository.getPartnerBranches();
      branches.assignAll(result.items);
      state.value = PartnerBranchesState.loaded;
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> openCreate() async {
    // AppPages registers named routes as GetPage<dynamic>. Requesting a concrete
    // result type here makes Navigator.pushNamed try to cast GetPageRoute<dynamic>
    // to Route<bool?>, which fails at runtime before the page can open.
    final result = await Get.toNamed<dynamic>(AppRoutes.partnerBranchCreate);
    if (result == true) await refreshBranches();
  }

  Future<void> openEdit(PartnerBranchData branch) async {
    final result = await Get.toNamed<dynamic>(
      AppRoutes.partnerBranchEditFor(branch.publicId),
    );
    if (result == true) await refreshBranches();
  }
}
