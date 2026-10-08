import '../models/scanner_partner_models.dart';
import 'partner_manager_repository.dart';
import 'scanner_partner_repository.dart';
import 'scanner_repository.dart';

/// Production-facing Scanner boundary over the preserved final integration
/// implementation. Feature controllers never receive the combined repository.
class ApiScannerRepository implements ScannerRepository {
  ApiScannerRepository(this.delegate);

  final ScannerPartnerRepository delegate;

  @override
  Future<ScannerContextData> getScannerContext() => delegate.getScannerContext();

  @override
  Future<SessionDetail> selectScannerBranch(SelectScannerBranchRequest request) =>
      delegate.selectScannerBranch(request);

  @override
  Future<List<PartnerBranchData>> getScannerBranches({String? query}) =>
      delegate.getScannerBranches(query: query);

  @override
  Future<List<ScannerDeviceData>> getScannerDevices({String? query}) =>
      delegate.getScannerDevices(query: query);

  @override
  Future<ScannerChallengeData> createQrChallenge(ScannerChallengeRequest request) =>
      delegate.createQrChallenge(request);

  @override
  Future<ScanVerificationData> verifyQr(VerifyQrRequest request) =>
      delegate.verifyQr(request);

  @override
  Future<ScanVerificationData> getScanResult(String scanPublicId) =>
      delegate.getScanResult(scanPublicId);

  @override
  Future<List<OfferDetails>> getEligibleOffers(String scanPublicId) =>
      delegate.getEligibleOffers(scanPublicId);

  @override
  Future<RedemptionReceipt> executeFreeRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  }) =>
      delegate.executeFreeRedemption(request, idempotencyKey: idempotencyKey);

  @override
  Future<RedemptionReceipt> executePointsRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  }) =>
      delegate.executePointsRedemption(request, idempotencyKey: idempotencyKey);

  @override
  Future<RedemptionReceipt> executeDiscountRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  }) =>
      delegate.executeDiscountRedemption(request, idempotencyKey: idempotencyKey);

  @override
  Future<PagedResult<RedemptionReceipt>> getRedemptions({
    ListQuery query = const ListQuery(),
  }) =>
      delegate.getRedemptions(query: query);

  @override
  Future<RedemptionReceipt> getRedemption(String redemptionPublicId) =>
      delegate.getRedemption(redemptionPublicId);

  @override
  Future<RedemptionReceipt> reverseRedemption(
    String redemptionPublicId,
    ReverseRedemptionRequest request, {
    required String idempotencyKey,
  }) =>
      delegate.reverseRedemption(
        redemptionPublicId,
        request,
        idempotencyKey: idempotencyKey,
      );

  @override
  Future<PartnerDailyStatisticsData> getDailyStatistics() =>
      delegate.getDailyStatistics();

  @override
  Future<PartnerDailyStatisticsData> getStatistics({required String period}) =>
      delegate.getStatistics(period: period);
}

/// Production-facing Partner boundary over the preserved final integration
/// implementation. Partner feature controllers cannot see Scanner methods.
class ApiPartnerManagerRepository implements PartnerManagerRepository {
  ApiPartnerManagerRepository(this.delegate);

  final ScannerPartnerRepository delegate;

  @override
  Future<PartnerDetail> getPartnerProfile() => delegate.getPartnerProfile();

  @override
  Future<PartnerDetail> requestPartnerProfileChange(
    RequestPartnerProfileChangeRequest request, {
    required String idempotencyKey,
  }) =>
      delegate.requestPartnerProfileChange(
        request,
        idempotencyKey: idempotencyKey,
      );

  @override
  Future<PagedResult<PartnerBranchData>> getPartnerBranches({
    ListQuery query = const ListQuery(),
  }) =>
      delegate.getPartnerBranches(query: query);

  @override
  Future<PartnerBranchData> createPartnerBranch(
    CreatePartnerBranchRequest request, {
    required String idempotencyKey,
  }) =>
      delegate.createPartnerBranch(request, idempotencyKey: idempotencyKey);

  @override
  Future<VersionedResource<PartnerBranchData>> getPartnerBranchForEdit(
    String branchPublicId,
  ) =>
      delegate.getPartnerBranchForEdit(branchPublicId);

  @override
  Future<VersionedResource<PartnerBranchData>> updatePartnerBranch(
    String branchPublicId,
    UpdatePartnerBranchRequest request,
  ) =>
      delegate.updatePartnerBranch(branchPublicId, request);

  @override
  Future<PagedResult<PartnerMembershipData>> getPartnerMemberships({
    ListQuery query = const ListQuery(),
  }) =>
      delegate.getPartnerMemberships(query: query);

  @override
  Future<PagedResult<OfferDetails>> getPartnerOffers({
    ListQuery query = const ListQuery(),
  }) =>
      delegate.getPartnerOffers(query: query);

  @override
  Future<OfferDetails> createPartnerOffer(
    CreatePartnerOfferRequest request, {
    required String idempotencyKey,
  }) =>
      delegate.createPartnerOffer(request, idempotencyKey: idempotencyKey);

  @override
  Future<VersionedResource<OfferDetails>> getPartnerOfferForEdit(
    String offerPublicId,
  ) =>
      delegate.getPartnerOfferForEdit(offerPublicId);

  @override
  Future<VersionedResource<OfferDetails>> updatePartnerOffer(
    String offerPublicId,
    UpdatePartnerOfferRequest request,
  ) =>
      delegate.updatePartnerOffer(offerPublicId, request);

  @override
  Future<OfferDetails> activatePartnerOffer(
    String offerPublicId, {
    required String idempotencyKey,
  }) =>
      delegate.activatePartnerOffer(
        offerPublicId,
        idempotencyKey: idempotencyKey,
      );

  @override
  Future<OfferDetails> disablePartnerOffer(
    String offerPublicId,
    DisablePartnerOfferRequest request, {
    required String idempotencyKey,
  }) =>
      delegate.disablePartnerOffer(
        offerPublicId,
        request,
        idempotencyKey: idempotencyKey,
      );
}
