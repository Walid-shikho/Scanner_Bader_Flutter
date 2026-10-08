import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/modules/home/controllers/home_controller.dart';
import 'package:scanner_partner/app/services/mock_scanner_partner_repository.dart';
import 'package:scanner_partner/core/network/api_error.dart';

void main() {
  test('home loads scanner context, branches, device, stats and recent redemptions',
      () async {
    final controller = HomeController(MockScannerPartnerRepository());

    await controller.loadDashboard();

    expect(controller.state.value, HomeDashboardState.loaded);
    expect(controller.scannerContext.value, isNotNull);
    expect(controller.scannerBranches, isNotEmpty);
    expect(controller.scannerDevices, isNotEmpty);
    expect(controller.dailyStatistics.value, isNotNull);
    expect(controller.recentRedemptions, isNotEmpty);
    expect(controller.canScan, isTrue);
  });

  test('branch switch updates current scanner context through repository',
      () async {
    final controller = HomeController(MockScannerPartnerRepository());
    await controller.loadDashboard();

    final target = controller.scannerBranches.last;
    await controller.selectBranch(target);

    expect(controller.state.value, HomeDashboardState.loaded);
    expect(controller.scannerContext.value?.branch?.publicId, target.publicId);
  });

  test('no selected branch and unavailable device keep dashboard loaded',
      () async {
    final controller = HomeController(_NoBranchDeviceRepository());

    await controller.loadDashboard();

    expect(controller.state.value, HomeDashboardState.loaded);
    expect(controller.hasSelectedBranch, isFalse);
    expect(controller.hasScannerDevice, isFalse);
    expect(controller.canScan, isFalse);
  });

  test('403 response maps to permission denied state', () async {
    final controller = HomeController(_PermissionDeniedRepository());

    await controller.loadDashboard();

    expect(controller.state.value, HomeDashboardState.permissionDenied);
  });

  test('empty redemption history remains a valid loaded state', () async {
    final controller = HomeController(_EmptyRedemptionsRepository());

    await controller.loadDashboard();

    expect(controller.state.value, HomeDashboardState.loaded);
    expect(controller.recentRedemptions, isEmpty);
  });
}

class _NoBranchDeviceRepository extends MockScannerPartnerRepository {
  @override
  Future<ScannerContextData> getScannerContext() async {
    final value = await super.getScannerContext();
    return ScannerContextData(
      partner: value.partner,
      membership: value.membership,
    );
  }

  @override
  Future<List<ScannerDeviceData>> getScannerDevices({String? query}) async {
    return const <ScannerDeviceData>[];
  }
}

class _PermissionDeniedRepository extends MockScannerPartnerRepository {
  @override
  Future<ScannerContextData> getScannerContext() async {
    throw NormalizedApiError(
      statusCode: 403,
      message: const ApiLocalizedText(ar: 'غير مسموح'),
      errors: const <ApiErrorItem>[],
      headers: const <String, String>{},
    );
  }
}

class _EmptyRedemptionsRepository extends MockScannerPartnerRepository {
  @override
  Future<PagedResult<RedemptionReceipt>> getRedemptions({
    ListQuery query = const ListQuery(),
  }) async {
    return PagedResult<RedemptionReceipt>(
      items: const <RedemptionReceipt>[],
      pagination: PaginationState(
        hasMore: false,
        limit: query.limit,
      ),
    );
  }
}
