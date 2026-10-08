import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/modules/qr_challenge/controllers/qr_challenge_controller.dart';
import 'package:scanner_partner/app/services/mock_scanner_partner_repository.dart';
import 'package:scanner_partner/app/services/qr_scanner_adapter.dart';
import 'package:scanner_partner/app/services/scanner_location_provider.dart';

void main() {
  test('flow creates challenge, scans, verifies, reads safe result, then loads offers',
      () async {
    final repository = _FlowRepository(result: ScanResultValue.eligible);
    final controller = QrChallengeController(
      repository,
      MockQrScannerAdapter(),
      MockScannerLocationProvider(permissionGranted: true),
    );

    await controller.prepareFlow();
    expect(controller.stage.value, QrScannerFlowStage.readyToScan);
    expect(repository.challengeCalls, 1);

    await controller.scanAndVerify();

    expect(repository.verifyCalls, 1);
    expect(repository.safeResultCalls, 1);
    expect(repository.offersCalls, 1);
    expect(repository.verificationIncludedOptionalLocation, isTrue);
    expect(controller.stage.value, QrScannerFlowStage.result);
    expect(controller.verificationResult.value?.scanResult,
        ScanResultValue.eligible);
    expect(controller.eligibleOffers, isNotEmpty);
  });

  test('ineligible result never requests eligible offers', () async {
    final repository = _FlowRepository(result: ScanResultValue.ineligible);
    final controller = QrChallengeController(
      repository,
      MockQrScannerAdapter(),
      MockScannerLocationProvider(),
    );

    await controller.prepareFlow();
    await controller.scanAndVerify();

    expect(controller.stage.value, QrScannerFlowStage.result);
    expect(controller.verificationResult.value?.scanResult,
        ScanResultValue.ineligible);
    expect(repository.offersCalls, 0);
    expect(controller.eligibleOffers, isEmpty);
  });

  test('verification works without optional location', () async {
    final repository = _FlowRepository(result: ScanResultValue.eligible);
    final controller = QrChallengeController(
      repository,
      MockQrScannerAdapter(),
      MockScannerLocationProvider(permissionGranted: false),
    );

    await controller.prepareFlow();
    await controller.scanAndVerify();

    expect(repository.verifyCalls, 1);
    expect(repository.verificationIncludedOptionalLocation, isFalse);
  });

  test('missing branch stops before challenge creation', () async {
    final repository = _NoBranchRepository();
    final controller = QrChallengeController(
      repository,
      MockQrScannerAdapter(),
      MockScannerLocationProvider(),
    );

    await controller.prepareFlow();

    expect(controller.stage.value, QrScannerFlowStage.branchRequired);
    expect(controller.branches, isNotEmpty);
    expect(repository.challengeCalls, 0);
  });
}

class _FlowRepository extends MockScannerPartnerRepository {
  _FlowRepository({required this.result});

  final ScanResultValue result;
  int challengeCalls = 0;
  int verifyCalls = 0;
  int safeResultCalls = 0;
  int offersCalls = 0;
  bool verificationIncludedOptionalLocation = false;

  @override
  Future<ScannerChallengeData> createQrChallenge(
    ScannerChallengeRequest request,
  ) async {
    challengeCalls += 1;
    return super.createQrChallenge(request);
  }

  @override
  Future<ScanVerificationData> verifyQr(VerifyQrRequest request) async {
    verifyCalls += 1;
    verificationIncludedOptionalLocation =
        request.latitude != null && request.longitude != null;
    return super.verifyQr(request);
  }

  @override
  Future<ScanVerificationData> getScanResult(String scanPublicId) async {
    safeResultCalls += 1;
    final base = await super.getScanResult(scanPublicId);
    return ScanVerificationData(
      scanPublicId: base.scanPublicId,
      scanResult: result,
      failureReasonCode: result == ScanResultValue.eligible ? null : 'mock',
      card: base.card,
      cardholder: base.cardholder,
      baderLinked: base.baderLinked,
      eligibleOfferCount: result == ScanResultValue.eligible ? 3 : 0,
      verifiedAt: base.verifiedAt,
      qrType: base.qrType,
      pinRequired: base.pinRequired,
      sensitiveRedemptionAllowed: base.sensitiveRedemptionAllowed,
    );
  }

  @override
  Future<List<OfferDetails>> getEligibleOffers(String scanPublicId) async {
    offersCalls += 1;
    return super.getEligibleOffers(scanPublicId);
  }
}

class _NoBranchRepository extends _FlowRepository {
  _NoBranchRepository() : super(result: ScanResultValue.eligible);

  @override
  Future<ScannerContextData> getScannerContext() async {
    final base = await super.getScannerContext();
    return ScannerContextData(
      partner: base.partner,
      membership: base.membership,
      scannerDevice: base.scannerDevice,
    );
  }
}
