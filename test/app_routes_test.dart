import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/routes/app_routes.dart';

void main() {
  test('current final application route constants are unique', () {
    const routes = <String>{
      AppRoutes.splash,
      AppRoutes.modeSelection,
      AppRoutes.login,
      AppRoutes.shell,
      AppRoutes.home,
      AppRoutes.partner,
      AppRoutes.settings,
      AppRoutes.scannerContext,
      AppRoutes.scannerBranches,
      AppRoutes.scannerDevices,
      AppRoutes.qrChallenge,
      AppRoutes.qrVerification,
      AppRoutes.scanResult,
      AppRoutes.eligibleOffers,
      AppRoutes.redemptions,
      AppRoutes.redemptionConfirm,
      AppRoutes.redemptionReceipt,
      AppRoutes.redemptionReverse,
      AppRoutes.redemptionDetails,
      AppRoutes.statistics,
      AppRoutes.partnerProfile,
      AppRoutes.partnerProfileChange,
      AppRoutes.partnerProfileOperationalEdit,
      AppRoutes.partnerNotifications,
      AppRoutes.partnerBranches,
      AppRoutes.partnerBranchCreate,
      AppRoutes.partnerBranchEdit,
      AppRoutes.memberships,
      AppRoutes.partnerOffers,
      AppRoutes.partnerOfferCreate,
      AppRoutes.partnerOfferEdit,
      AppRoutes.partnerOfferActivate,
      AppRoutes.partnerOfferDisable,
      AppRoutes.partnerOfferDetails,
    };
    expect(routes.length, 34);
  });
}
