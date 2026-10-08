import '../routes/app_routes.dart';
import 'scanner_session_state.dart';

class ScannerRouteRequirement {
  const ScannerRouteRequirement({
    required this.principal,
    required this.permission,
    required this.registeredScannerRequired,
    this.stepUpRequired = false,
  });

  final ScannerPrincipalType principal;
  final ScannerPermission permission;
  final bool registeredScannerRequired;
  final bool stepUpRequired;
}

/// Declarative contract metadata only.
///
/// Phase 3 deliberately does not install an authorization middleware. Once the
/// external authentication/session contract exists, route guards can consume
/// this table instead of relying on client-selected roles or client role claims.
abstract final class ScannerRouteRequirements {
  static const byRoute = <String, ScannerRouteRequirement>{
    AppRoutes.scannerContext: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.scannerUse,
      registeredScannerRequired: true,
    ),
    AppRoutes.scannerBranches: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.scannerUse,
      registeredScannerRequired: true,
    ),
    AppRoutes.scannerDevices: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.scannerUse,
      registeredScannerRequired: true,
    ),
    AppRoutes.qrChallenge: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.scannerUse,
      registeredScannerRequired: true,
    ),
    AppRoutes.qrVerification: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.scannerUse,
      registeredScannerRequired: true,
    ),
    AppRoutes.scanResult: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.scannerUse,
      registeredScannerRequired: true,
    ),
    AppRoutes.eligibleOffers: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.scannerUse,
      registeredScannerRequired: true,
    ),
    AppRoutes.redemptions: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.redemptionsView,
      registeredScannerRequired: true,
    ),
    AppRoutes.redemptionDetails: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.redemptionsView,
      registeredScannerRequired: true,
    ),
    AppRoutes.redemptionConfirm: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.redemptionsExecute,
      registeredScannerRequired: true,
    ),
    AppRoutes.redemptionReverse: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.redemptionsReverse,
      registeredScannerRequired: true,
      stepUpRequired: true,
    ),
    AppRoutes.statistics: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.redemptionsStats,
      registeredScannerRequired: true,
    ),
    AppRoutes.partnerProfile: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.partnerRead,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerProfileChange: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.partnerProfileRequestChange,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerBranches: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.partnerBranchesView,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerBranchCreate: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.partnerBranchesCreate,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerBranchEdit: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.partnerBranchesUpdate,
      registeredScannerRequired: false,
    ),
    AppRoutes.memberships: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.partnerMembersView,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerOffers: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.offersManage,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerOfferCreate: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.offersCreate,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerOfferDetails: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.offersManage,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerOfferEdit: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.offersUpdate,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerOfferActivate: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.offersActivate,
      registeredScannerRequired: false,
    ),
    AppRoutes.partnerOfferDisable: ScannerRouteRequirement(
      principal: ScannerPrincipalType.partnerEmployee,
      permission: ScannerPermission.offersDisable,
      registeredScannerRequired: false,
    ),
  };
}
