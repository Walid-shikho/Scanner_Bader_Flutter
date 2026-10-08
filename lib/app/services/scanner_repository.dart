import '../models/scanner_partner_models.dart';

/// Scanner-only repository boundary. Scanner controllers must depend on this
/// interface rather than the combined legacy contract.
abstract interface class ScannerRepository {
  Future<ScannerContextData> getScannerContext();
  Future<SessionDetail> selectScannerBranch(SelectScannerBranchRequest request);
  Future<List<PartnerBranchData>> getScannerBranches({String? query});
  Future<List<ScannerDeviceData>> getScannerDevices({String? query});
  Future<ScannerChallengeData> createQrChallenge(ScannerChallengeRequest request);
  Future<ScanVerificationData> verifyQr(VerifyQrRequest request);
  Future<ScanVerificationData> getScanResult(String scanPublicId);
  Future<List<OfferDetails>> getEligibleOffers(String scanPublicId);
  Future<RedemptionReceipt> executeFreeRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  });
  Future<RedemptionReceipt> executePointsRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  });
  Future<RedemptionReceipt> executeDiscountRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  });
  Future<PagedResult<RedemptionReceipt>> getRedemptions({
    ListQuery query = const ListQuery(),
  });
  Future<RedemptionReceipt> getRedemption(String redemptionPublicId);
  Future<RedemptionReceipt> reverseRedemption(
    String redemptionPublicId,
    ReverseRedemptionRequest request, {
    required String idempotencyKey,
  });
  Future<PartnerDailyStatisticsData> getDailyStatistics();
  Future<PartnerDailyStatisticsData> getStatistics({required String period});
}
