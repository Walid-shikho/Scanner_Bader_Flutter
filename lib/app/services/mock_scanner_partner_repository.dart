import 'dart:async';

import 'package:get/get.dart';

import '../../core/network/api_error.dart';
import '../models/scanner_partner_models.dart';
import 'partner_type_taxonomy_source.dart';
import 'qr_scanner_adapter.dart';
import 'scanner_partner_repository.dart';

class OfflineDemoValidationException implements Exception {
  const OfflineDemoValidationException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'OfflineDemoValidationException($code: $message)';
}

class OfflinePendingPartnerProfileChange {
  const OfflinePendingPartnerProfileChange({
    required this.publicId,
    required this.changes,
    required this.reason,
    required this.createdAt,
    required this.status,
  });

  final String publicId;
  final PartnerProfileChanges changes;
  final String reason;
  final DateTime createdAt;
  final String status;
}

/// Deterministic, network-free repository for UI development.
///
/// No sensitive request value is logged or persisted. QR verification has no
/// redemption side effect; redemption occurs only through the explicit
/// redemption methods.
class MockScannerPartnerRepository extends GetxService
    implements ScannerPartnerRepository {
  static const _delay = Duration(milliseconds: 80);
  static final _baseTime = DateTime.parse('2026-10-06T08:24:12Z');
  static const int _defaultPointsOfferCost = 300;

  static const _partnerId = '0198a6f0-7b8c-7a12-9abc-1234567890ab';
  static const _membershipId = '0198a6f1-7b8c-7a12-9abc-1234567890ab';
  static const _branchOneId = '0198a6f2-7b8c-7a12-9abc-1234567890ab';
  static const _branchTwoId = '0198a6f3-7b8c-7a12-9abc-1234567890ab';
  static const _branchSuspendedId = '0198a6fb-7b8c-7a12-9abc-1234567890ab';
  static const _deviceId = '0198a6f4-7b8c-7a12-9abc-1234567890ab';
  static const _scanId = '0198a6f5-7b8c-7a12-9abc-1234567890ab';
  static const _cardId = '0198a6f6-7b8c-7a12-9abc-1234567890ab';
  static const _cardTypeId = '0198a6f7-7b8c-7a12-9abc-1234567890ab';
  static const _offerFreeId = '0198a6f8-7b8c-7a12-9abc-1234567890ab';
  static const _offerPointsId = '0198a6f9-7b8c-7a12-9abc-1234567890ab';
  static const _offerPercentageId = '0198a6fa-7b8c-7a12-9abc-1234567890ab';
  static const _offerFixedId = '0198a6fc-7b8c-7a12-9abc-1234567890ab';
  static const _offerDisabledId = '0198a6fd-7b8c-7a12-9abc-2234567890ab';

  late String _selectedBranchPublicId = _branchOneId;
  late final Map<String, String> _branchEtags = <String, String>{
    _branchOneId: '"branch-v1"',
    _branchTwoId: '"branch-v1"',
  };
  int _createdBranchSequence = 0;

  late final Map<String, String> _offerEtags = <String, String>{
    _offerFreeId: '"offer-v1"',
    _offerPointsId: '"offer-v1"',
    _offerPercentageId: '"offer-v1"',
    _offerFixedId: '"offer-v1"',
  };
  int _createdOfferSequence = 0;
  final Map<String, OfferDetails> _idempotentOfferMutationResponses =
      <String, OfferDetails>{};


  final List<RedemptionReceipt> _redemptions = <RedemptionReceipt>[
    RedemptionReceipt(
      publicId: '0198b001-7b8c-7a12-9abc-1234567890ab',
      entryType: 'redemption',
      result: 'completed',
      quantity: 1,
      invoiceAmount: '250000.00',
      discountAmount: '50000.00',
      currencyCode: 'SYP',
      occurredAt: _baseTime,
    ),
    RedemptionReceipt(
      publicId: '0198b004-7b8c-7a12-9abc-1234567890ab',
      entryType: 'redemption',
      result: 'completed',
      quantity: 1,
      pointsCostSnapshot: _defaultPointsOfferCost,
      occurredAt: _baseTime.subtract(const Duration(hours: 1)),
    ),
    RedemptionReceipt(
      publicId: '0198b005-7b8c-7a12-9abc-1234567890ab',
      entryType: 'redemption',
      result: 'completed',
      quantity: 1,
      invoiceAmount: '120000.00',
      currencyCode: 'SYP',
      occurredAt: _baseTime.subtract(const Duration(hours: 2)),
    ),
    RedemptionReceipt(
      publicId: '0198b006-7b8c-7a12-9abc-1234567890ab',
      entryType: 'redemption',
      result: 'failed',
      failureReasonCode: 'CONFLICT_STATE',
      quantity: 1,
      occurredAt: _baseTime.subtract(const Duration(hours: 3)),
    ),
    RedemptionReceipt(
      publicId: '0198b007-7b8c-7a12-9abc-1234567890ab',
      entryType: 'redemption',
      result: 'completed',
      quantity: 1,
      pointsCostSnapshot: 150,
      occurredAt: _baseTime.subtract(const Duration(days: 1)),
    ),
  ];

  final Map<String, RedemptionReceipt> _idempotentRedemptionResponses =
      <String, RedemptionReceipt>{};
  final Map<String, ScanVerificationData> _offlineScanResults =
      <String, ScanVerificationData>{};
  final List<OfflinePendingPartnerProfileChange>
      _pendingPartnerProfileChangeRequests =
      <OfflinePendingPartnerProfileChange>[];
  final Map<String, OfflinePendingPartnerProfileChange>
      _idempotentPartnerProfileChangeRequests =
      <String, OfflinePendingPartnerProfileChange>{};
  int _offlineWalletPoints = 1500;

  int get offlineWalletPoints => _offlineWalletPoints;

  List<OfflinePendingPartnerProfileChange> get pendingPartnerProfileChangeRequests =>
      List<OfflinePendingPartnerProfileChange>.unmodifiable(
        _pendingPartnerProfileChangeRequests,
      );

  Future<void> _wait() => Future<void>.delayed(_delay);

  late final List<PartnerBranchData> _branches = <PartnerBranchData>[
        PartnerBranchData(
          publicId: _branchOneId,
          code: 'DAM-01',
          nameAr: 'الفرع الرئيسي',
          nameEn: 'Main Branch',
          phone: '+963000000001',
          location: const LocationSummary(
            latitude: 33.5138,
            longitude: 36.2765,
            address: 'Damascus',
          ),
          workingHours: const <WorkingHoursEntry>[
            WorkingHoursEntry(
              day: WorkingDay.sun,
              opensAt: '09:00:00',
              closesAt: '18:00:00',
              closed: false,
            ),
          ],
          status: 'active',
          createdAt: _baseTime,
          updatedAt: _baseTime,
        ),
        PartnerBranchData(
          publicId: _branchTwoId,
          code: 'DAM-02',
          nameAr: 'الفرع الثاني',
          nameEn: 'Second Branch',
          phone: '+963000000002',
          location: const LocationSummary(
            latitude: 33.5200,
            longitude: 36.2900,
            address: 'Damascus',
          ),
          workingHours: const <WorkingHoursEntry>[
            WorkingHoursEntry(
              day: WorkingDay.sun,
              opensAt: '10:00:00',
              closesAt: '19:00:00',
              closed: false,
            ),
          ],
          status: 'active',
          createdAt: _baseTime,
          updatedAt: _baseTime,
        ),
        PartnerBranchData(
          publicId: _branchSuspendedId,
          code: 'ALP-03',
          nameAr: 'فرع حلب التجريبي',
          nameEn: 'Aleppo Demo Branch',
          phone: '+963000000003',
          location: const LocationSummary(
            latitude: 36.2021,
            longitude: 37.1343,
            address: 'Aleppo',
          ),
          workingHours: const <WorkingHoursEntry>[],
          status: 'suspended',
          createdAt: _baseTime,
          updatedAt: _baseTime,
        ),
      ];

  ScannerDeviceData get _scannerDevice => ScannerDeviceData(
        publicId: _deviceId,
        status: 'active',
        trustLevel: 'trusted',
        attestationProvider: 'platform',
        attestationStatus: 'verified',
        registeredAt: _baseTime,
        activatedAt: _baseTime,
      );

  TaxonomyRef get _cardType => const TaxonomyRef(
        publicId: _cardTypeId,
        code: 'standard',
        name: LocalizedMessage(
          ar: 'بطاقة قياسية',
          en: 'Standard Card',
          de: 'Standardkarte',
        ),
      );

  TaxonomyRef get _partnerType => MockPartnerTypeTaxonomyCatalog.values.first;

  ScanVerificationData get _verifiedScan => ScanVerificationData(
        scanPublicId: _scanId,
        scanResult: ScanResultValue.eligible,
        card: VerifiedCardData(
          publicId: _cardId,
          status: 'active',
          cardType: _cardType,
          expiresAt: DateTime.parse('2028-10-06T08:24:12Z'),
        ),
        cardholder: const CardholderSummary(displayName: 'Card Holder'),
        baderLinked: true,
        eligibleOfferCount: 4,
        verifiedAt: _baseTime,
        qrType: ScannerQrType.dynamicQr,
        pinRequired: false,
        sensitiveRedemptionAllowed: true,
      );

  late final List<OfferDetails> _offers = <OfferDetails>[
        OfferDetails(
          publicId: _offerFreeId,
          discountType: 'free',
          titleAr: 'ميزة مجانية',
          titleEn: 'Free Benefit',
          descriptionAr: 'عرض تجريبي مطابق لنوع free في العقد.',
          descriptionEn: 'Deterministic mock offer for the free contract type.',
          startsAt: _baseTime,
          endsAt: DateTime.parse('2026-12-31T23:59:59Z'),
          status: 'active',
          isExclusive: false,
          successfulUsageCount: 8,
          approvedAt: _baseTime,
          createdAt: _baseTime,
          updatedAt: _baseTime,
        ),
        OfferDetails(
          publicId: _offerPointsId,
          discountType: 'points',
          titleAr: 'ميزة بالنقاط',
          titleEn: 'Points Benefit',
          pointsCost: _defaultPointsOfferCost,
          startsAt: _baseTime,
          endsAt: DateTime.parse('2026-12-31T23:59:59Z'),
          status: 'active',
          isExclusive: true,
          successfulUsageCount: 4,
          approvedAt: _baseTime,
          createdAt: _baseTime,
          updatedAt: _baseTime,
        ),
        OfferDetails(
          publicId: _offerPercentageId,
          discountType: 'percentage',
          titleAr: 'خصم نسبة',
          titleEn: 'Percentage Discount',
          discountValue: 20,
          currencyCode: 'SYP',
          startsAt: _baseTime,
          endsAt: DateTime.parse('2026-12-31T23:59:59Z'),
          status: 'active',
          isExclusive: false,
          successfulUsageCount: 2,
          approvedAt: _baseTime,
          createdAt: _baseTime,
          updatedAt: _baseTime,
        ),
        OfferDetails(
          publicId: _offerFixedId,
          discountType: 'fixed',
          titleAr: 'خصم ثابت',
          titleEn: 'Fixed Discount',
          discountValue: 25000,
          currencyCode: 'SYP',
          startsAt: _baseTime,
          endsAt: DateTime.parse('2026-12-31T23:59:59Z'),
          status: 'active',
          isExclusive: false,
          successfulUsageCount: 1,
          approvedAt: _baseTime,
          createdAt: _baseTime,
          updatedAt: _baseTime,
        ),
        OfferDetails(
          publicId: _offerDisabledId,
          discountType: 'free',
          titleAr: 'عرض تجريبي متوقف',
          titleEn: 'Disabled Demo Offer',
          descriptionAr: 'عرض محلي لاختبار حالة التعطيل وإعادة التفعيل.',
          descriptionEn: 'Offline fixture used to test disabled/activate states.',
          startsAt: _baseTime,
          endsAt: DateTime.parse('2026-12-31T23:59:59Z'),
          status: 'disabled',
          isExclusive: false,
          successfulUsageCount: 0,
          approvedAt: _baseTime,
          createdAt: _baseTime,
          updatedAt: _baseTime,
        ),
      ];

  late PartnerDetail _partnerDetail = PartnerDetail(
        publicId: _partnerId,
        legalName: 'Bader Demo Partner LLC',
        displayName: 'Bader Demo Store',
        description: 'Offline demo partner for testing the complete Partner Manager experience.',
        businessRegistration: 'OFFLINE-DEMO-2026',
        contactEmail: 'partner@bader.local',
        contactPhone: '+963 11 555 0101',
        addressLine: 'Damascus - Offline Demo Branch',
        latitude: 33.5138,
        longitude: 36.2765,
        status: 'active',
        approvedAt: _baseTime,
        createdAt: _baseTime,
        updatedAt: _baseTime,
      );

  int _cursorOffset(String? cursor) {
    if (cursor == null || cursor.isEmpty) return 0;
    const prefix = 'mock-redemptions-cursor-';
    if (!cursor.startsWith(prefix)) return 0;
    return int.tryParse(cursor.substring(prefix.length)) ?? 0;
  }

  PagedResult<T> _pagedResult<T>(List<T> values, ListQuery query) {
    final limit = query.limit < 1 ? 1 : query.limit;
    final offset = _cursorOffset(query.cursor).clamp(0, values.length).toInt();
    final end = (offset + limit).clamp(0, values.length).toInt();
    final page = values.sublist(offset, end);
    final hasMore = end < values.length;
    return PagedResult<T>(
      items: List<T>.unmodifiable(page),
      pagination: PaginationState(
        hasMore: hasMore,
        limit: limit,
        nextCursor: hasMore ? 'mock-redemptions-cursor-$end' : null,
        previousCursor: offset > 0 ? 'mock-redemptions-cursor-0' : null,
      ),
    );
  }

  PaginationState _pagination(ListQuery query) => PaginationState(
        hasMore: false,
        limit: query.limit,
        nextCursor: null,
        previousCursor: query.cursor,
      );

  String _maskPhone(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= 4) return '••••';
    final suffix = trimmed.substring(trimmed.length - 3);
    final prefixLength = trimmed.startsWith('+') ? 4 : 2;
    final prefix = trimmed.substring(0,
        prefixLength.clamp(0, trimmed.length).toInt());
    return '$prefix••••••$suffix';
  }

  String _maskEmail(String value) {
    final trimmed = value.trim();
    final at = trimmed.indexOf('@');
    if (at <= 0) return '•••';
    return '${trimmed.substring(0, 1)}***${trimmed.substring(at)}';
  }

  List<T> _filterByText<T>(
    List<T> values,
    String? query,
    String Function(T value) text,
  ) {
    final needle = query?.trim().toLowerCase();
    if (needle == null || needle.isEmpty) {
      return List<T>.unmodifiable(values);
    }
    return List<T>.unmodifiable(
      values.where((value) => text(value).toLowerCase().contains(needle)),
    );
  }

  @override
  Future<ScannerContextData> getScannerContext() async {
    await _wait();
    final branch = _branches.firstWhere(
      (item) => item.publicId == _selectedBranchPublicId,
    );
    return ScannerContextData(
      partner: const PartnerContextData(
        publicId: _partnerId,
        displayName: 'Partner Store',
        status: 'active',
      ),
      membership: const MembershipContextData(
        publicId: _membershipId,
        roleCode: 'scanner',
        status: 'active',
      ),
      branch: branch,
      scannerDevice: _scannerDevice,
    );
  }

  @override
  Future<List<PartnerBranchData>> getScannerBranches({String? query}) async {
    await _wait();
    return _filterByText(
      _branches.where((branch) => branch.status == 'active').toList(growable: false),
      query,
      (branch) => '${branch.code} ${branch.nameAr} ${branch.nameEn ?? ''}',
    );
  }

  @override
  Future<SessionDetail> selectScannerBranch(
    SelectScannerBranchRequest request,
  ) async {
    await _wait();
    _branches.firstWhere((item) => item.publicId == request.branchPublicId);
    _selectedBranchPublicId = request.branchPublicId;
    return SessionDetail(
      publicId: '0198c001-7b8c-7a12-9abc-1234567890ab',
      status: 'active',
      startedAt: _baseTime,
      lastSeenAt: _baseTime,
      expiresAt: DateTime.parse('2026-11-05T08:24:12Z'),
    );
  }

  @override
  Future<List<ScannerDeviceData>> getScannerDevices({String? query}) async {
    await _wait();
    return _filterByText(
      <ScannerDeviceData>[_scannerDevice],
      query,
      (device) => '${device.publicId} ${device.status} ${device.trustLevel}',
    );
  }

  @override
  Future<ScannerChallengeData> createQrChallenge(
    ScannerChallengeRequest request,
  ) async {
    await _wait();
    _branches.firstWhere((item) => item.publicId == request.branchPublicId);
    return ScannerChallengeData(
      challengePublicId: '0198d001-7b8c-7a12-9abc-1234567890ab',
      challengeToken: 'mock_scanner_challenge_value_never_log_or_persist',
      expiresAt: DateTime.parse('2026-10-06T08:25:42Z'),
    );
  }

  @override
  Future<ScanVerificationData> verifyQr(VerifyQrRequest request) async {
    await _wait();
    _branches.firstWhere((item) => item.publicId == request.branchPublicId);

    final scenario = _scenarioFromToken(request.signedQrToken);
    final result = _verificationForScenario(scenario);
    _offlineScanResults[result.scanPublicId] = result;
    return result;
  }

  @override
  Future<ScanVerificationData> getScanResult(String scanPublicId) async {
    await _wait();
    final result = _offlineScanResults[scanPublicId];
    if (result != null) return result;
    if (scanPublicId == _scanId) return _verifiedScan;
    throw StateError('Offline demo scan not found');
  }

  @override
  Future<List<OfferDetails>> getEligibleOffers(String scanPublicId) async {
    await _wait();
    final scan = _offlineScanResults[scanPublicId];
    if (scan != null && scan.eligibleOfferCount == 0) {
      return const <OfferDetails>[];
    }
    if (scan == null && scanPublicId != _scanId) {
      throw StateError('Offline demo scan not found');
    }
    return List<OfferDetails>.unmodifiable(_offers.where((offer) => offer.status == 'active'));
  }

  OfflineQrScenario _scenarioFromToken(String token) {
    for (final scenario in OfflineQrScenario.values) {
      if (token == scenario.token) return scenario;
    }
    return OfflineQrScenario.invalid;
  }

  ScanVerificationData _verificationForScenario(OfflineQrScenario scenario) {
    final scanId = 'offline-scan-${scenario.name}';
    final qrType = scenario == OfflineQrScenario.validStatic
        ? ScannerQrType.staticQr
        : ScannerQrType.dynamicQr;
    final scanResult = switch (scenario) {
      OfflineQrScenario.expired => ScanResultValue.expired,
      OfflineQrScenario.replayed => ScanResultValue.replayed,
      OfflineQrScenario.invalid => ScanResultValue.invalid,
      _ => ScanResultValue.eligible,
    };
    final eligibleCount = scenario == OfflineQrScenario.noEligibleOffers ||
            scanResult != ScanResultValue.eligible
        ? 0
        : _offers.where((offer) => offer.status == 'active').length;
    return ScanVerificationData(
      scanPublicId: scanId,
      scanResult: scanResult,
      failureReasonCode: switch (scenario) {
        OfflineQrScenario.expired => 'offline_expired_qr',
        OfflineQrScenario.replayed => 'offline_replayed_qr',
        OfflineQrScenario.invalid => 'offline_invalid_qr',
        _ => null,
      },
      card: VerifiedCardData(
        publicId: _cardId,
        status: 'active',
        cardType: _cardType,
        expiresAt: DateTime.parse('2028-10-06T08:24:12Z'),
      ),
      cardholder: const CardholderSummary(displayName: 'Offline Demo Card Holder'),
      baderLinked: true,
      eligibleOfferCount: eligibleCount,
      verifiedAt: _baseTime,
      qrType: qrType,
      pinRequired: scenario == OfflineQrScenario.validStatic,
      sensitiveRedemptionAllowed: scanResult == ScanResultValue.eligible,
    );
  }

  @override
  Future<RedemptionReceipt> executeFreeRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  }) async {
    await _wait();
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError.value(idempotencyKey, 'idempotencyKey');
    }
    final cacheKey = 'free:$idempotencyKey';
    final replay = _idempotentRedemptionResponses[cacheKey];
    if (replay != null) return replay;

    final receipt = RedemptionReceipt(
      publicId:
          '0198b1${(_redemptions.length + 10).toString().padLeft(2, '0')}-7b8c-7a12-9abc-1234567890ab',
      entryType: 'redemption',
      result: 'completed',
      quantity: 1,
      invoiceAmount: request.invoiceAmount,
      currencyCode: request.invoiceAmount == null ? null : 'SYP',
      occurredAt: _baseTime.add(Duration(minutes: _redemptions.length + 1)),
    );
    _idempotentRedemptionResponses[cacheKey] = receipt;
    _redemptions.insert(0, receipt);
    _incrementOfferUsage(request.offerPublicId);
    return receipt;
  }

  @override
  Future<RedemptionReceipt> executePointsRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  }) async {
    await _wait();
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError.value(idempotencyKey, 'idempotencyKey');
    }
    final cacheKey = 'points:$idempotencyKey';
    final replay = _idempotentRedemptionResponses[cacheKey];
    if (replay != null) return replay;

    final offerIndex = _offers.indexWhere(
      (item) => item.publicId == request.offerPublicId,
    );
    if (offerIndex < 0) {
      throw const OfflineDemoValidationException(
        'OFFLINE_POINTS_OFFER_NOT_FOUND',
        'The selected Offline points offer does not exist.',
      );
    }
    final offer = _offers[offerIndex];
    if (offer.discountType != PartnerOfferType.points.wireValue) {
      throw const OfflineDemoValidationException(
        'OFFLINE_POINTS_OFFER_TYPE_INVALID',
        'The selected Offline offer is not a points offer.',
      );
    }
    final pointsCost = offer.pointsCost;
    if (pointsCost == null || pointsCost <= 0) {
      throw const OfflineDemoValidationException(
        'OFFLINE_POINTS_COST_INVALID',
        'The selected Offline points offer has no valid points cost.',
      );
    }
    if (_offlineWalletPoints < pointsCost) {
      throw const OfflineDemoValidationException(
        'OFFLINE_INSUFFICIENT_POINTS',
        'The Offline wallet does not have enough points for this offer.',
      );
    }

    final receipt = RedemptionReceipt(
      publicId:
          '0198b2${(_redemptions.length + 10).toString().padLeft(2, '0')}-7b8c-7a12-9abc-1234567890ab',
      entryType: 'redemption',
      result: 'completed',
      quantity: 1,
      invoiceAmount: request.invoiceAmount,
      currencyCode: request.invoiceAmount == null ? null : 'SYP',
      pointsCostSnapshot: pointsCost,
      occurredAt: _baseTime.add(Duration(minutes: _redemptions.length + 2)),
    );
    _idempotentRedemptionResponses[cacheKey] = receipt;
    _redemptions.insert(0, receipt);
    _offlineWalletPoints -= pointsCost;
    _incrementOfferUsage(request.offerPublicId);
    return receipt;
  }

  @override
  Future<RedemptionReceipt> executeDiscountRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  }) async {
    await _wait();
    if (request.invoiceAmount == null || request.invoiceAmount!.isEmpty) {
      throw ArgumentError('invoice_amount is required for offline discount demo.');
    }
    final replay = _idempotentRedemptionResponses['discount:$idempotencyKey'];
    if (replay != null) return replay;
    final invoice = double.parse(request.invoiceAmount!);
    final offer = _offers.firstWhere((item) => item.publicId == request.offerPublicId);
    final rawDiscount = offer.discountType == 'percentage'
        ? invoice * ((offer.discountValue ?? 0).toDouble() / 100)
        : (offer.discountValue ?? 0).toDouble();
    final discount = rawDiscount.clamp(0, invoice).toDouble();
    final receipt = RedemptionReceipt(
      publicId: 'offline-redemption-${_redemptions.length + 1}',
      entryType: 'redemption',
      result: 'completed',
      quantity: 1,
      invoiceAmount: invoice.toStringAsFixed(2),
      discountAmount: discount.toStringAsFixed(2),
      currencyCode: 'SYP',
      occurredAt: _baseTime.add(Duration(minutes: _redemptions.length + 4)),
    );
    _idempotentRedemptionResponses['discount:$idempotencyKey'] = receipt;
    _redemptions.insert(0, receipt);
    _incrementOfferUsage(request.offerPublicId);
    return receipt;
  }

  @override
  Future<PagedResult<RedemptionReceipt>> getRedemptions({
    ListQuery query = const ListQuery(),
  }) async {
    await _wait();
    final filtered = _filterByText(
      _redemptions,
      query.q,
      (item) =>
          '${item.entryType} ${item.result} ${item.currencyCode ?? ''} ${item.failureReasonCode ?? ''}',
    );
    return _pagedResult(filtered, query);
  }

  @override
  Future<RedemptionReceipt> getRedemption(String redemptionPublicId) async {
    await _wait();
    return _redemptions.firstWhere(
      (item) => item.publicId == redemptionPublicId,
    );
  }

  @override
  Future<RedemptionReceipt> reverseRedemption(
    String redemptionPublicId,
    ReverseRedemptionRequest request, {
    required String idempotencyKey,
  }) async {
    await _wait();
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError.value(idempotencyKey, 'idempotencyKey');
    }
    final original = _redemptions.firstWhere(
      (item) => item.publicId == redemptionPublicId,
    );
    final cacheKey = 'reverse:$redemptionPublicId:$idempotencyKey';
    final replay = _idempotentRedemptionResponses[cacheKey];
    if (replay != null) return replay;

    final originalIndex = _redemptions.indexWhere(
      (item) => item.publicId == redemptionPublicId,
    );
    _redemptions[originalIndex] = RedemptionReceipt(
      publicId: original.publicId,
      entryType: original.entryType,
      result: 'reversed',
      quantity: original.quantity,
      failureReasonCode: original.failureReasonCode,
      invoiceAmount: original.invoiceAmount,
      discountAmount: original.discountAmount,
      currencyCode: original.currencyCode,
      pointsCostSnapshot: original.pointsCostSnapshot,
      externalReference: original.externalReference,
      reversalReason: request.reason,
      occurredAt: original.occurredAt,
    );

    final receipt = RedemptionReceipt(
      publicId:
          '0198b3${(_redemptions.length + 10).toString().padLeft(2, '0')}-7b8c-7a12-9abc-1234567890ab',
      entryType: 'reversal',
      result: 'completed',
      quantity: original.quantity,
      invoiceAmount: original.invoiceAmount,
      discountAmount: original.discountAmount,
      currencyCode: original.currencyCode,
      pointsCostSnapshot: original.pointsCostSnapshot,
      reversalReason: request.reason,
      occurredAt: _baseTime.add(Duration(minutes: _redemptions.length + 3)),
    );
    _idempotentRedemptionResponses[cacheKey] = receipt;
    _redemptions.insert(0, receipt);
    _offlineWalletPoints += original.pointsCostSnapshot ?? 0;
    return receipt;
  }

  @override
  Future<PartnerDailyStatisticsData> getDailyStatistics() =>
      getStatistics(period: 'daily');

  @override
  Future<PartnerDailyStatisticsData> getStatistics({required String period}) async {
    await _wait();
    final normalizedPeriod = switch (period) {
      'weekly' => 'weekly',
      'monthly' => 'monthly',
      _ => 'daily',
    };
    final successful = _redemptions.where((item) =>
        item.entryType == 'redemption' && item.result == 'completed').toList();
    final failed = _redemptions.where((item) => item.result == 'failed').length;
    final totalDiscount = successful.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.discountAmount ?? '') ?? 0),
    );
    final points = successful.fold<int>(
      0,
      (sum, item) => sum + (item.pointsCostSnapshot ?? 0),
    );
    return PartnerDailyStatisticsData(
      date: normalizedPeriod == 'daily' ? '2026-10-06' : normalizedPeriod,
      successfulRedemptions: successful.length,
      failedRedemptions: failed,
      totalDiscountAmount: totalDiscount.toStringAsFixed(2),
      pointsSpent: points,
    );
  }

  Future<PartnerDetail> offlineUpdateOperationalProfile({
    required String contactEmail,
    required String contactPhone,
    required String address,
    required String description,
  }) async {
    await _wait();
    _partnerDetail = PartnerDetail(
      publicId: _partnerDetail.publicId,
      legalName: _partnerDetail.legalName,
      displayName: _partnerDetail.displayName,
      description: description,
      businessRegistration: _partnerDetail.businessRegistration,
      logoFilePublicId: _partnerDetail.logoFilePublicId,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      addressLine: address,
      latitude: _partnerDetail.latitude,
      longitude: _partnerDetail.longitude,
      status: _partnerDetail.status,
      approvedAt: _partnerDetail.approvedAt,
      createdAt: _partnerDetail.createdAt,
      updatedAt: _baseTime.add(const Duration(minutes: 32)),
    );
    return _partnerDetail;
  }

  @override
  Future<PartnerDetail> getPartnerProfile() async {
    await _wait();
    return _partnerDetail;
  }

  @override
  Future<PartnerDetail> requestPartnerProfileChange(
    RequestPartnerProfileChangeRequest request, {
    required String idempotencyKey,
  }) async {
    await _wait();
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError.value(idempotencyKey, 'idempotencyKey');
    }
    final replay = _idempotentPartnerProfileChangeRequests[idempotencyKey];
    if (replay != null) return _partnerDetail;

    final pending = OfflinePendingPartnerProfileChange(
      publicId:
          'offline-profile-change-${_pendingPartnerProfileChangeRequests.length + 1}',
      changes: request.changes,
      reason: request.reason,
      createdAt: _baseTime.add(
        Duration(minutes: 30 + _pendingPartnerProfileChangeRequests.length),
      ),
      status: 'pending',
    );
    _pendingPartnerProfileChangeRequests.add(pending);
    _idempotentPartnerProfileChangeRequests[idempotencyKey] = pending;

    // A protected profile change is a request only. The canonical PartnerDetail
    // remains unchanged until a future approval simulation explicitly applies it.
    return _partnerDetail;
  }

  @override
  Future<PagedResult<PartnerBranchData>> getPartnerBranches({
    ListQuery query = const ListQuery(),
  }) async {
    await _wait();
    final items = _filterByText(
      _branches,
      query.q,
      (branch) => '${branch.code} ${branch.nameAr} ${branch.nameEn ?? ''}',
    );
    return PagedResult<PartnerBranchData>(
      items: items,
      pagination: _pagination(query),
    );
  }

  @override
  Future<PartnerBranchData> createPartnerBranch(
    CreatePartnerBranchRequest request, {
    required String idempotencyKey,
  }) async {
    await _wait();
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError.value(idempotencyKey, 'idempotencyKey');
    }
    _createdBranchSequence += 1;
    final suffix = (_createdBranchSequence + 20).toString().padLeft(2, '0');
    final created = PartnerBranchData(
      publicId: '0198a7$suffix-7b8c-7a12-9abc-1234567890ab',
      code: 'NEW-${_createdBranchSequence.toString().padLeft(2, '0')}',
      nameAr: request.name,
      phone: request.phone,
      location: LocationSummary(
        latitude: request.latitude,
        longitude: request.longitude,
        address: request.address,
      ),
      workingHours: const <WorkingHoursEntry>[],
      status: 'active',
      createdAt: _baseTime.add(Duration(minutes: _createdBranchSequence)),
      updatedAt: _baseTime.add(Duration(minutes: _createdBranchSequence)),
    );
    _branches.add(created);
    _branchEtags[created.publicId] = '"branch-v1"';
    return created;
  }

  @override
  Future<VersionedResource<PartnerBranchData>> getPartnerBranchForEdit(
    String branchPublicId,
  ) async {
    await _wait();
    final branch = _branches.firstWhere(
      (item) => item.publicId == branchPublicId,
    );
    return VersionedResource<PartnerBranchData>(
      data: branch,
      etag: _branchEtags[branchPublicId] ?? '"branch-v1"',
    );
  }

  @override
  Future<VersionedResource<PartnerBranchData>> updatePartnerBranch(
    String branchPublicId,
    UpdatePartnerBranchRequest request,
  ) async {
    await _wait();
    final index = _branches.indexWhere(
      (item) => item.publicId == branchPublicId,
    );
    if (index < 0) {
      throw StateError('Mock branch not found');
    }

    final existing = _branches[index];
    final updated = PartnerBranchData(
      publicId: existing.publicId,
      code: existing.code,
      nameAr: request.name.isPresent
          ? (request.name.value ?? existing.nameAr)
          : existing.nameAr,
      nameEn: existing.nameEn,
      phone: request.phone.isPresent ? request.phone.value : existing.phone,
      location: LocationSummary(
        latitude: request.latitude.isPresent
            ? request.latitude.value
            : existing.location?.latitude,
        longitude: request.longitude.isPresent
            ? request.longitude.value
            : existing.location?.longitude,
        address: request.address.isPresent
            ? request.address.value
            : existing.location?.address,
      ),
      workingHours: existing.workingHours,
      status: existing.status,
      createdAt: existing.createdAt,
      updatedAt: _baseTime.add(const Duration(minutes: 3)),
    );
    _branches[index] = updated;
    final currentEtag = _branchEtags[branchPublicId] ?? '"branch-v1"';
    final version = int.tryParse(
          RegExp(r'v(\d+)').firstMatch(currentEtag)?.group(1) ?? '1',
        ) ??
        1;
    final nextEtag = '"branch-v${version + 1}"';
    _branchEtags[branchPublicId] = nextEtag;
    return VersionedResource<PartnerBranchData>(
      data: updated,
      etag: nextEtag,
    );
  }

  @override
  Future<PagedResult<PartnerMembershipData>> getPartnerMemberships({
    ListQuery query = const ListQuery(),
  }) async {
    await _wait();

    final members = <PartnerMembershipData>[
      PartnerMembershipData(
        publicId: '0198a6f1-7b8c-7a12-9abc-1234567890ab',
        user: const PartnerMemberUserData(
          publicId: '0198e001-7b8c-7a12-9abc-1234567890ab',
          displayName: 'Offline Partner Admin',
          verifiedBadge: true,
        ),
        roleCode: 'partner_admin',
        status: 'active',
        startedAt: _baseTime,
        createdAt: _baseTime,
        updatedAt: _baseTime,
      ),
      PartnerMembershipData(
        publicId: '0198a6fd-7b8c-7a12-9abc-1234567890ab',
        user: const PartnerMemberUserData(
          publicId: '0198e002-7b8c-7a12-9abc-1234567890ab',
          displayName: 'Offline Branch Manager',
          verifiedBadge: true,
        ),
        branch: _branches[0],
        roleCode: 'branch_manager',
        status: 'active',
        startedAt: _baseTime,
        createdAt: _baseTime,
        updatedAt: _baseTime,
      ),
      PartnerMembershipData(
        publicId: '0198a6fe-7b8c-7a12-9abc-1234567890ab',
        user: const PartnerMemberUserData(
          publicId: '0198e003-7b8c-7a12-9abc-1234567890ab',
          displayName: 'Offline Partner Staff',
          verifiedBadge: false,
        ),
        roleCode: 'partner_staff',
        status: 'active',
        startedAt: _baseTime,
        createdAt: _baseTime,
        updatedAt: _baseTime,
      ),
      PartnerMembershipData(
        publicId: '0198a6ff-7b8c-7a12-9abc-1234567890ab',
        user: const PartnerMemberUserData(
          publicId: '0198e004-7b8c-7a12-9abc-1234567890ab',
          displayName: 'Offline Branch Staff',
          verifiedBadge: false,
        ),
        branch: _branches[1],
        roleCode: 'branch_staff',
        status: 'active',
        startedAt: _baseTime,
        createdAt: _baseTime,
        updatedAt: _baseTime,
      ),
      PartnerMembershipData(
        publicId: '0198a700-7b8c-7a12-9abc-1234567890ab',
        user: const PartnerMemberUserData(
          publicId: '0198e005-7b8c-7a12-9abc-1234567890ab',
          displayName: 'Offline Scanner Operator',
          verifiedBadge: true,
        ),
        branch: _branches[0],
        roleCode: 'scanner',
        status: 'active',
        startedAt: _baseTime,
        createdAt: _baseTime,
        updatedAt: _baseTime,
      )
    ];

    final filtered = _filterByText(
      members,
      query.q,
      (item) {
        final branch = item.branch;
        return '${item.user.displayName} ${item.roleCode} ${item.status} '
            '${branch?.code ?? ''} ${branch?.nameAr ?? ''} ${branch?.nameEn ?? ''}';
      },
    );

    final limit = query.limit < 1 ? 1 : query.limit;
    const cursorPrefix = 'mock-memberships-cursor-';
    var offset = 0;
    final cursor = query.cursor;
    if (cursor != null && cursor.startsWith(cursorPrefix)) {
      offset = int.tryParse(cursor.substring(cursorPrefix.length)) ?? 0;
    }
    offset = offset.clamp(0, filtered.length).toInt();
    final end = (offset + limit).clamp(0, filtered.length).toInt();
    final page = filtered.sublist(offset, end);
    final hasMore = end < filtered.length;

    return PagedResult<PartnerMembershipData>(
      items: List<PartnerMembershipData>.unmodifiable(page),
      pagination: PaginationState(
        hasMore: hasMore,
        limit: limit,
        nextCursor: hasMore ? '$cursorPrefix$end' : null,
        previousCursor: offset > 0 ? '${cursorPrefix}0' : null,
      ),
    );
  }

  @override
  Future<PagedResult<OfferDetails>> getPartnerOffers({
    ListQuery query = const ListQuery(),
  }) async {
    await _wait();
    final filtered = _filterByText(
      _offers,
      query.q,
      (item) => '${item.titleAr} ${item.titleEn ?? ''} '
          '${item.descriptionAr ?? ''} ${item.descriptionEn ?? ''} '
          '${item.discountType} ${item.status}',
    );

    final limit = query.limit < 1 ? 1 : query.limit;
    const cursorPrefix = 'mock-offers-cursor-';
    var offset = 0;
    final cursor = query.cursor;
    if (cursor != null && cursor.startsWith(cursorPrefix)) {
      offset = int.tryParse(cursor.substring(cursorPrefix.length)) ?? 0;
    }
    offset = offset.clamp(0, filtered.length).toInt();
    final end = (offset + limit).clamp(0, filtered.length).toInt();
    final page = filtered.sublist(offset, end);
    final hasMore = end < filtered.length;

    return PagedResult<OfferDetails>(
      items: List<OfferDetails>.unmodifiable(page),
      pagination: PaginationState(
        hasMore: hasMore,
        limit: limit,
        nextCursor: hasMore ? '$cursorPrefix$end' : null,
        previousCursor: offset > 0 ? '${cursorPrefix}0' : null,
      ),
    );
  }

  @override
  Future<OfferDetails> createPartnerOffer(
    CreatePartnerOfferRequest request, {
    required String idempotencyKey,
  }) async {
    await _wait();
    final replay = _idempotentOfferMutationResponses['create:$idempotencyKey'];
    if (replay != null) return replay;

    _createdOfferSequence += 1;
    final now = _baseTime.add(Duration(minutes: 20 + _createdOfferSequence));
    final created = OfferDetails(
      publicId:
          '0198d${_createdOfferSequence.toString().padLeft(3, '0')}-7b8c-7a12-9abc-1234567890ab',
      discountType: request.offerType.wireValue,
      titleAr: request.name.ar,
      titleEn: request.name.en,
      descriptionAr: request.description.ar,
      descriptionEn: request.description.en,
      discountValue: request.value == null ? null : num.tryParse(request.value!),
      pointsCost: request.pointsCost,
      startsAt: request.startsAt ?? now,
      endsAt: request.endsAt ?? now.add(const Duration(days: 30)),
      status: 'draft',
      isExclusive: false,
      successfulUsageCount: 0,
      createdAt: now,
      updatedAt: now,
    );
    _offers.insert(0, created);
    _offerEtags[created.publicId] = '"offer-v1"';
    _idempotentOfferMutationResponses['create:$idempotencyKey'] = created;
    return created;
  }

  @override
  Future<VersionedResource<OfferDetails>> getPartnerOfferForEdit(
    String offerPublicId,
  ) async {
    await _wait();
    final offer = _offers.firstWhere((item) => item.publicId == offerPublicId);
    return VersionedResource<OfferDetails>(
      data: offer,
      etag: _offerEtags[offerPublicId] ?? '"offer-v1"',
    );
  }

  @override
  Future<VersionedResource<OfferDetails>> updatePartnerOffer(
    String offerPublicId,
    UpdatePartnerOfferRequest request,
  ) async {
    await _wait();
    final index = _offers.indexWhere((item) => item.publicId == offerPublicId);
    if (index < 0) throw StateError('Mock offer not found');


    final existing = _offers[index];
    final updated = OfferDetails(
      publicId: existing.publicId,
      discountType: existing.discountType,
      titleAr: request.name?.ar ?? existing.titleAr,
      titleEn: request.name != null ? request.name!.en : existing.titleEn,
      descriptionAr: request.description?.ar ?? existing.descriptionAr,
      descriptionEn:
          request.description != null ? request.description!.en : existing.descriptionEn,
      discountValue: request.value.isPresent
          ? (request.value.value == null
              ? null
              : num.tryParse(request.value.value!))
          : existing.discountValue,
      currencyCode: existing.currencyCode,
      termsText: existing.termsText,
      pointsCost: request.pointsCost.isPresent
          ? request.pointsCost.value
          : existing.pointsCost,
      startsAt: request.startsAt.isPresent
          ? (request.startsAt.value ?? existing.startsAt)
          : existing.startsAt,
      endsAt: request.endsAt.isPresent
          ? (request.endsAt.value ?? existing.endsAt)
          : existing.endsAt,
      status: existing.status,
      isExclusive: existing.isExclusive,
      maxUsesPerCard: existing.maxUsesPerCard,
      maxUsesTotal: existing.maxUsesTotal,
      maxUsesPerDay: existing.maxUsesPerDay,
      successfulUsageCount: existing.successfulUsageCount,
      approvedAt: existing.approvedAt,
      createdAt: existing.createdAt,
      updatedAt: _baseTime.add(const Duration(minutes: 24)),
    );
    _offers[index] = updated;
    final currentEtag = _offerEtags[offerPublicId] ?? '"offer-v1"';
    final version = int.tryParse(
          RegExp(r'v(\d+)').firstMatch(currentEtag)?.group(1) ?? '1',
        ) ??
        1;
    final nextEtag = '"offer-v${version + 1}"';
    _offerEtags[offerPublicId] = nextEtag;
    return VersionedResource<OfferDetails>(data: updated, etag: nextEtag);
  }

  @override
  Future<OfferDetails> activatePartnerOffer(
    String offerPublicId, {
    required String idempotencyKey,
  }) async {
    await _wait();
    final replay =
        _idempotentOfferMutationResponses['activate:$offerPublicId:$idempotencyKey'];
    if (replay != null) return replay;
    final index = _offers.indexWhere((item) => item.publicId == offerPublicId);
    if (index < 0) throw StateError('Mock offer not found');
    final updated = _copyOffer(_offers[index], status: 'active');
    _offers[index] = updated;
    _idempotentOfferMutationResponses[
        'activate:$offerPublicId:$idempotencyKey'] = updated;
    return updated;
  }

  @override
  Future<OfferDetails> disablePartnerOffer(
    String offerPublicId,
    DisablePartnerOfferRequest request, {
    required String idempotencyKey,
  }) async {
    await _wait();
    final replay =
        _idempotentOfferMutationResponses['disable:$offerPublicId:$idempotencyKey'];
    if (replay != null) return replay;
    final index = _offers.indexWhere((item) => item.publicId == offerPublicId);
    if (index < 0) throw StateError('Mock offer not found');
    final updated = _copyOffer(_offers[index], status: 'disabled');
    _offers[index] = updated;
    _idempotentOfferMutationResponses[
        'disable:$offerPublicId:$idempotencyKey'] = updated;
    return updated;
  }

  OfferDetails _copyOffer(OfferDetails value, {required String status}) {
    return OfferDetails(
      publicId: value.publicId,
      discountType: value.discountType,
      titleAr: value.titleAr,
      titleEn: value.titleEn,
      descriptionAr: value.descriptionAr,
      descriptionEn: value.descriptionEn,
      discountValue: value.discountValue,
      currencyCode: value.currencyCode,
      termsText: value.termsText,
      startsAt: value.startsAt,
      endsAt: value.endsAt,
      status: status,
      isExclusive: value.isExclusive,
      pointsCost: value.pointsCost,
      maxUsesPerCard: value.maxUsesPerCard,
      maxUsesTotal: value.maxUsesTotal,
      maxUsesPerDay: value.maxUsesPerDay,
      successfulUsageCount: value.successfulUsageCount,
      approvedAt: value.approvedAt,
      createdAt: value.createdAt,
      updatedAt: _baseTime.add(const Duration(minutes: 25)),
    );
  }

  void _incrementOfferUsage(String offerPublicId) {
    final index = _offers.indexWhere((item) => item.publicId == offerPublicId);
    if (index < 0) return;
    final offer = _offers[index];
    _offers[index] = OfferDetails(
      publicId: offer.publicId,
      discountType: offer.discountType,
      titleAr: offer.titleAr,
      titleEn: offer.titleEn,
      descriptionAr: offer.descriptionAr,
      descriptionEn: offer.descriptionEn,
      discountValue: offer.discountValue,
      currencyCode: offer.currencyCode,
      termsText: offer.termsText,
      startsAt: offer.startsAt,
      endsAt: offer.endsAt,
      status: offer.status,
      isExclusive: offer.isExclusive,
      pointsCost: offer.pointsCost,
      maxUsesPerCard: offer.maxUsesPerCard,
      maxUsesTotal: offer.maxUsesTotal,
      maxUsesPerDay: offer.maxUsesPerDay,
      successfulUsageCount: offer.successfulUsageCount + 1,
      approvedAt: offer.approvedAt,
      createdAt: offer.createdAt,
      updatedAt: _baseTime.add(const Duration(minutes: 31)),
    );
  }

}
