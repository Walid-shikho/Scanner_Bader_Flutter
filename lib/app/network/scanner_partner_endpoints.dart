import 'final_partner_scanner_api_inventory.dart';

/// Runtime path helpers for the final 64-endpoint Partner/Scanner contract.
/// Exact endpoint metadata lives in [FinalPartnerScannerApiInventory].
abstract final class ScannerPartnerEndpoints {
  static const scannerContext = '/api/v1/scanner/context';
  static const scannerBranches = '/api/v1/scanner/branches';
  static const scannerContextBranch = '/api/v1/scanner/context/branch';
  static const scannerDevices = '/api/v1/scanner/devices';
  static const scannerQrChallenge = '/api/v1/scanner/qr/challenge';
  static const scannerQrVerify = '/api/v1/scanner/qr/verify';
  static const scannerRedemptionsFree = '/api/v1/scanner/redemptions/free';
  static const scannerRedemptionsPoints = '/api/v1/scanner/redemptions/points';
  static const scannerRedemptionsDiscount = '/api/v1/scanner/redemptions/discount';
  static const scannerRedemptions = '/api/v1/scanner/redemptions';
  static const scannerStatisticsDaily = '/api/v1/scanner/statistics/daily';
  static const scannerStatistics = '/api/v1/scanner/statistics';

  static const partnerMe = '/api/v1/partner/me';
  static const partnerProfileChangeRequests = '/api/v1/partner/me/profile-change-requests';
  static const partnerProfile = '/api/v1/partner/me/profile';
  static const partnerPassword = '/api/v1/partner/me/password';
  static const partnerBranches = '/api/v1/partner/me/branches';
  static const partnerMemberships = '/api/v1/partner/me/memberships';
  static const partnerOffers = '/api/v1/partner/me/offers';
  static const partnerNotifications = '/api/v1/partner/me/notifications';
  static const partnerNotificationsUnread = '/api/v1/partner/me/notifications/unread-count';
  static const partnerNotificationsReadAll = '/api/v1/partner/me/notifications/read-all';
  static const partnerNotificationPreferences = '/api/v1/partner/me/notification-preferences';

  static String scannerScan(String scanPublicId) =>
      '/api/v1/scanner/scans/${Uri.encodeComponent(scanPublicId)}';
  static String scannerEligibleOffers(String scanPublicId) =>
      '${scannerScan(scanPublicId)}/eligible-offers';
  static String scannerRedemption(String redemptionPublicId) =>
      '$scannerRedemptions/${Uri.encodeComponent(redemptionPublicId)}';
  static String scannerRedemptionReverse(String redemptionPublicId) =>
      '${scannerRedemption(redemptionPublicId)}/reverse';
  static String partnerBranch(String branchPublicId) =>
      '$partnerBranches/${Uri.encodeComponent(branchPublicId)}';
  static String partnerOffer(String offerPublicId) =>
      '$partnerOffers/${Uri.encodeComponent(offerPublicId)}';
  static String partnerOfferActivate(String offerPublicId) =>
      '${partnerOffer(offerPublicId)}/activate';
  static String partnerOfferDisable(String offerPublicId) =>
      '${partnerOffer(offerPublicId)}/disable';
  static String partnerNotificationRead(String notificationPublicId) =>
      '$partnerNotifications/${Uri.encodeComponent(notificationPublicId)}/read';

  static List<FinalApiEndpoint> get definitions =>
      FinalPartnerScannerApiInventory.endpoints;
}
