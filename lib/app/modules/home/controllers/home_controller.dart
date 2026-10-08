import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/scanner_repository.dart';

enum HomeDashboardState {
  loading,
  loaded,
  permissionDenied,
  serverError,
}

class HomeController extends GetxController {
  HomeController(this.repository);

  final ScannerRepository repository;

  final state = HomeDashboardState.loading.obs;
  final scannerContext = Rxn<ScannerContextData>();
  final dailyStatistics = Rxn<PartnerDailyStatisticsData>();
  final scannerBranches = <PartnerBranchData>[].obs;
  final scannerDevices = <ScannerDeviceData>[].obs;
  final recentRedemptions = <RedemptionReceipt>[].obs;
  final isRefreshing = false.obs;
  final isSwitchingBranch = false.obs;

  bool get hasSelectedBranch => scannerContext.value?.branch != null;

  bool get hasScannerDevice => scannerContext.value?.scannerDevice != null;

  bool get canScan =>
      state.value == HomeDashboardState.loaded &&
      hasSelectedBranch &&
      hasScannerDevice &&
      !isSwitchingBranch.value;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else if (scannerContext.value == null) {
      state.value = HomeDashboardState.loading;
    }

    try {
      final results = await Future.wait<Object?>([
        repository.getScannerContext(),
        repository.getScannerBranches(),
        repository.getScannerDevices(),
        repository.getDailyStatistics(),
        repository.getRedemptions(query: const ListQuery(limit: 20)),
      ]);

      scannerContext.value = results[0]! as ScannerContextData;
      scannerBranches.assignAll(results[1]! as List<PartnerBranchData>);
      scannerDevices.assignAll(results[2]! as List<ScannerDeviceData>);
      dailyStatistics.value = results[3]! as PartnerDailyStatisticsData;

      final redemptionPage = results[4]! as PagedResult<RedemptionReceipt>;
      final sortedRedemptions = redemptionPage.items.toList(growable: false)
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
      recentRedemptions.assignAll(sortedRedemptions.take(3));

      state.value = HomeDashboardState.loaded;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? HomeDashboardState.permissionDenied
          : HomeDashboardState.serverError;
    } catch (_) {
      state.value = HomeDashboardState.serverError;
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> refreshDashboard() => loadDashboard(refresh: true);

  Future<void> selectBranch(PartnerBranchData branch) async {
    if (isSwitchingBranch.value ||
        scannerContext.value?.branch?.publicId == branch.publicId) {
      return;
    }

    isSwitchingBranch.value = true;
    try {
      await repository.selectScannerBranch(
        SelectScannerBranchRequest(branchPublicId: branch.publicId),
      );
      await loadDashboard(refresh: true);
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? HomeDashboardState.permissionDenied
          : HomeDashboardState.serverError;
    } catch (_) {
      state.value = HomeDashboardState.serverError;
    } finally {
      isSwitchingBranch.value = false;
    }
  }

  void openScan() {
    if (!canScan) return;
    Get.toNamed<void>(AppRoutes.qrChallenge);
  }

  void openRedemptions() => Get.toNamed<void>(AppRoutes.redemptions);

  void openStatistics() => Get.toNamed<void>(AppRoutes.statistics);

  void openSettings() => Get.toNamed<void>(AppRoutes.settings);
}
