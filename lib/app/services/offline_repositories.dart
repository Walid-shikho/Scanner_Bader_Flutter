import 'package:get/get.dart';

import '../models/scanner_partner_models.dart';
import 'mock_scanner_partner_repository.dart';
import 'partner_manager_repository.dart';
import 'scanner_repository.dart';

/// Shared deterministic state engine for the two isolated Offline repository
/// boundaries. It performs no network I/O.
class OfflineDemoState extends GetxService {
  OfflineDemoState() : engine = MockScannerPartnerRepository();

  final MockScannerPartnerRepository engine;
}

class OfflineScannerRepository extends GetxService implements ScannerRepository {
  OfflineScannerRepository(this.state);
  final OfflineDemoState state;
  MockScannerPartnerRepository get _engine => state.engine;

  @override Future<ScannerContextData> getScannerContext() => _engine.getScannerContext();
  @override Future<SessionDetail> selectScannerBranch(SelectScannerBranchRequest request) => _engine.selectScannerBranch(request);
  @override Future<List<PartnerBranchData>> getScannerBranches({String? query}) => _engine.getScannerBranches(query: query);
  @override Future<List<ScannerDeviceData>> getScannerDevices({String? query}) => _engine.getScannerDevices(query: query);
  @override Future<ScannerChallengeData> createQrChallenge(ScannerChallengeRequest request) => _engine.createQrChallenge(request);
  @override Future<ScanVerificationData> verifyQr(VerifyQrRequest request) => _engine.verifyQr(request);
  @override Future<ScanVerificationData> getScanResult(String scanPublicId) => _engine.getScanResult(scanPublicId);
  @override Future<List<OfferDetails>> getEligibleOffers(String scanPublicId) => _engine.getEligibleOffers(scanPublicId);
  @override Future<RedemptionReceipt> executeFreeRedemption(RedemptionRequest request, {required String idempotencyKey}) => _engine.executeFreeRedemption(request, idempotencyKey: idempotencyKey);
  @override Future<RedemptionReceipt> executePointsRedemption(RedemptionRequest request, {required String idempotencyKey}) => _engine.executePointsRedemption(request, idempotencyKey: idempotencyKey);
  @override Future<RedemptionReceipt> executeDiscountRedemption(RedemptionRequest request, {required String idempotencyKey}) => _engine.executeDiscountRedemption(request, idempotencyKey: idempotencyKey);
  @override Future<PagedResult<RedemptionReceipt>> getRedemptions({ListQuery query = const ListQuery()}) => _engine.getRedemptions(query: query);
  @override Future<RedemptionReceipt> getRedemption(String redemptionPublicId) => _engine.getRedemption(redemptionPublicId);
  @override Future<RedemptionReceipt> reverseRedemption(String redemptionPublicId, ReverseRedemptionRequest request, {required String idempotencyKey}) => _engine.reverseRedemption(redemptionPublicId, request, idempotencyKey: idempotencyKey);
  @override Future<PartnerDailyStatisticsData> getDailyStatistics() => _engine.getDailyStatistics();
  @override Future<PartnerDailyStatisticsData> getStatistics({required String period}) => _engine.getStatistics(period: period);
}

class OfflinePartnerManagerRepository extends GetxService
    implements PartnerManagerRepository {
  OfflinePartnerManagerRepository(this.state);
  final OfflineDemoState state;
  MockScannerPartnerRepository get _engine => state.engine;

  @override Future<PartnerDetail> getPartnerProfile() => _engine.getPartnerProfile();
  @override Future<PartnerDetail> requestPartnerProfileChange(RequestPartnerProfileChangeRequest request, {required String idempotencyKey}) => _engine.requestPartnerProfileChange(request, idempotencyKey: idempotencyKey);
  @override Future<PagedResult<PartnerBranchData>> getPartnerBranches({ListQuery query = const ListQuery()}) => _engine.getPartnerBranches(query: query);
  @override Future<PartnerBranchData> createPartnerBranch(CreatePartnerBranchRequest request, {required String idempotencyKey}) => _engine.createPartnerBranch(request, idempotencyKey: idempotencyKey);
  @override Future<VersionedResource<PartnerBranchData>> getPartnerBranchForEdit(String branchPublicId) => _engine.getPartnerBranchForEdit(branchPublicId);
  @override Future<VersionedResource<PartnerBranchData>> updatePartnerBranch(String branchPublicId, UpdatePartnerBranchRequest request) => _engine.updatePartnerBranch(branchPublicId, request);
  @override Future<PagedResult<PartnerMembershipData>> getPartnerMemberships({ListQuery query = const ListQuery()}) => _engine.getPartnerMemberships(query: query);
  @override Future<PagedResult<OfferDetails>> getPartnerOffers({ListQuery query = const ListQuery()}) => _engine.getPartnerOffers(query: query);
  @override Future<OfferDetails> createPartnerOffer(CreatePartnerOfferRequest request, {required String idempotencyKey}) => _engine.createPartnerOffer(request, idempotencyKey: idempotencyKey);
  @override Future<VersionedResource<OfferDetails>> getPartnerOfferForEdit(String offerPublicId) => _engine.getPartnerOfferForEdit(offerPublicId);
  @override Future<VersionedResource<OfferDetails>> updatePartnerOffer(String offerPublicId, UpdatePartnerOfferRequest request) => _engine.updatePartnerOffer(offerPublicId, request);
  @override Future<OfferDetails> activatePartnerOffer(String offerPublicId, {required String idempotencyKey}) => _engine.activatePartnerOffer(offerPublicId, idempotencyKey: idempotencyKey);
  @override Future<OfferDetails> disablePartnerOffer(String offerPublicId, DisablePartnerOfferRequest request, {required String idempotencyKey}) => _engine.disablePartnerOffer(offerPublicId, request, idempotencyKey: idempotencyKey);
}
