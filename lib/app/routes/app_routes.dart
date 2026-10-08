abstract final class AppRoutes {
  static const splash = '/splash';
  static const modeSelection = '/mode-selection';
  static const login = '/login';
  static const shell = '/';
  static const home = '/home';
  static const partner = '/partner';
  static const settings = '/settings';

  // Scanner runtime feature groups.
  static const scannerContext = '/scanner/context';
  static const scannerBranches = '/scanner/branches';
  static const scannerDevices = '/scanner/devices';
  static const qrChallenge = '/scanner/qr/challenge';
  static const qrVerification = '/scanner/qr/verify';
  static const scanResult = '/scanner/scans/:scan_public_id';
  static const eligibleOffers =
      '/scanner/scans/:scan_public_id/eligible-offers';

  static String eligibleOffersFor(String scanPublicId) =>
      '/scanner/scans/$scanPublicId/eligible-offers';
  static const redemptions = '/scanner/redemptions';
  static const redemptionConfirm = '/scanner/redemptions/confirm';
  static const redemptionReceipt = '/scanner/redemptions/receipt';
  static const redemptionReverse =
      '/scanner/redemptions/:redemption_public_id/reverse';
  static const redemptionDetails =
      '/scanner/redemptions/:redemption_public_id';
  static const statistics = '/scanner/statistics/daily';

  static String redemptionDetailsFor(String redemptionPublicId) =>
      '/scanner/redemptions/$redemptionPublicId';

  static String redemptionReverseFor(String redemptionPublicId) =>
      '/scanner/redemptions/$redemptionPublicId/reverse';

  // Partner employee self-management.
  static const partnerProfile = '/partner/me';
  static const partnerProfileChange = '/partner/me/profile-change-request';
  static const partnerProfileOperationalEdit = '/partner/me/profile/edit';
  static const partnerNotifications = '/partner/me/notifications';
  static const partnerBranches = '/partner/me/branches';
  static const partnerBranchCreate = '/partner/me/branches/new';
  static const partnerBranchEdit =
      '/partner/me/branches/:branch_public_id/edit';

  static String partnerBranchEditFor(String branchPublicId) =>
      '/partner/me/branches/$branchPublicId/edit';
  static const memberships = '/partner/me/memberships';
  static const partnerOffers = '/partner/me/offers';
  static const partnerOfferCreate = '/partner/me/offers/new';
  static const partnerOfferDetails = '/partner/me/offers/:offer_public_id';
  static const partnerOfferEdit = '/partner/me/offers/:offer_public_id/edit';
  static const partnerOfferActivate =
      '/partner/me/offers/:offer_public_id/activate';
  static const partnerOfferDisable =
      '/partner/me/offers/:offer_public_id/disable';

  static String partnerOfferDetailsFor(String offerPublicId) =>
      '/partner/me/offers/$offerPublicId';

  static String partnerOfferEditFor(String offerPublicId) =>
      '/partner/me/offers/$offerPublicId/edit';

  static String partnerOfferActivateFor(String offerPublicId) =>
      '/partner/me/offers/$offerPublicId/activate';

  static String partnerOfferDisableFor(String offerPublicId) =>
      '/partner/me/offers/$offerPublicId/disable';
}
