import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/redemption_flow_models.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/qr_scanner_adapter.dart';
import '../../../services/scanner_location_provider.dart';
import '../../../services/scanner_repository.dart';

enum QrScannerFlowStage {
  loadingContext,
  branchRequired,
  deviceUnavailable,
  creatingChallenge,
  readyToScan,
  scanning,
  verifying,
  result,
  permissionDenied,
  serverError,
}

class QrChallengeController extends GetxController {
  QrChallengeController(
    this.repository,
    this.scannerAdapter,
    this.locationProvider,
  );

  final ScannerRepository repository;
  final QrScannerAdapter scannerAdapter;
  final ScannerLocationProvider locationProvider;

  final stage = QrScannerFlowStage.loadingContext.obs;
  final scannerContext = Rxn<ScannerContextData>();
  final branches = <PartnerBranchData>[].obs;
  final verificationResult = Rxn<ScanVerificationData>();
  final eligibleOffers = <OfferDetails>[].obs;
  final isOffersLoading = false.obs;
  final offersLoadFailed = false.obs;
  final isSelectingBranch = false.obs;

  ScannerChallengeData? _challenge;
  String? _signedQrToken;

  bool get hasSelectedBranch => scannerContext.value?.branch != null;
  bool get hasScannerDevice => scannerContext.value?.scannerDevice != null;
  bool get canScan => stage.value == QrScannerFlowStage.readyToScan;

  bool get isOfflineDemoScanner => scannerAdapter is OfflineQrScannerAdapter;
  List<OfflineQrScenario> get demoScenarios => OfflineQrScenario.values;
  OfflineQrScenario get selectedDemoScenario => scannerAdapter is OfflineQrScannerAdapter
      ? (scannerAdapter as OfflineQrScannerAdapter).selectedScenario.value
      : OfflineQrScenario.validDynamic;

  void selectDemoScenario(OfflineQrScenario scenario) {
    final adapter = scannerAdapter;
    if (adapter is OfflineQrScannerAdapter) adapter.selectScenario(scenario);
  }

  bool get shouldLoadEligibleOffers {
    final result = verificationResult.value;
    return result != null &&
        result.scanResult == ScanResultValue.eligible &&
        result.eligibleOfferCount > 0;
  }

  @override
  void onInit() {
    super.onInit();
    prepareFlow();
  }

  @override
  void onClose() {
    _clearTransientQrState();
    unawaited(scannerAdapter.cancel());
    super.onClose();
  }

  Future<void> prepareFlow() async {
    _clearTransientQrState();
    verificationResult.value = null;
    eligibleOffers.clear();
    offersLoadFailed.value = false;
    isOffersLoading.value = false;
    stage.value = QrScannerFlowStage.loadingContext;

    try {
      final context = await repository.getScannerContext();
      scannerContext.value = context;

      if (context.branch == null) {
        final availableBranches = await repository.getScannerBranches();
        branches.assignAll(availableBranches);
        stage.value = QrScannerFlowStage.branchRequired;
        return;
      }

      if (context.scannerDevice == null) {
        stage.value = QrScannerFlowStage.deviceUnavailable;
        return;
      }

      await _createChallenge(context.branch!);
    } on NormalizedApiError catch (error) {
      _setApiFailure(error);
    } catch (_) {
      stage.value = QrScannerFlowStage.serverError;
    }
  }

  Future<void> selectBranch(PartnerBranchData branch) async {
    if (isSelectingBranch.value) return;

    isSelectingBranch.value = true;
    try {
      await repository.selectScannerBranch(
        SelectScannerBranchRequest(branchPublicId: branch.publicId),
      );
      await prepareFlow();
    } on NormalizedApiError catch (error) {
      _setApiFailure(error);
    } catch (_) {
      stage.value = QrScannerFlowStage.serverError;
    } finally {
      isSelectingBranch.value = false;
    }
  }

  Future<void> scanAndVerify() async {
    if (!canScan) return;

    final context = scannerContext.value;
    final challenge = _challenge;
    final branch = context?.branch;
    if (context == null || branch == null || challenge == null) {
      await prepareFlow();
      return;
    }

    stage.value = QrScannerFlowStage.scanning;

    try {
      final capture = await scannerAdapter.scan();
      if (capture == null) {
        stage.value = QrScannerFlowStage.readyToScan;
        return;
      }

      _signedQrToken = capture.signedQrToken;
      stage.value = QrScannerFlowStage.verifying;

      ScannerLocationSample? optionalLocation;
      try {
        optionalLocation = await locationProvider.currentLocationIfGranted();
      } catch (_) {
        // Location is optional under API-0196. A location-provider failure must
        // not prevent verification or be converted into fake authorization.
        optionalLocation = null;
      }

      final verified = await repository.verifyQr(
        VerifyQrRequest(
          signedQrToken: _signedQrToken!,
          scannerChallenge: ScannerChallengeText(challenge.challengeToken),
          branchPublicId: branch.publicId,
          latitude: optionalLocation?.latitude,
          longitude: optionalLocation?.longitude,
        ),
      );

      // The challenge and signed QR token are no longer needed once the verify
      // request completes. Clear them before any subsequent repository call.
      _clearTransientQrState();

      // API-0197 is the canonical safe scan-result read used for presentation.
      final safeResult = await repository.getScanResult(verified.scanPublicId);
      verificationResult.value = safeResult;
      stage.value = QrScannerFlowStage.result;

      if (shouldLoadEligibleOffers) {
        await loadEligibleOffers();
      }
    } on NormalizedApiError catch (error) {
      _clearTransientQrState();
      _setApiFailure(error);
    } catch (_) {
      _clearTransientQrState();
      stage.value = QrScannerFlowStage.serverError;
    }
  }

  Future<void> loadEligibleOffers() async {
    final result = verificationResult.value;
    if (result == null ||
        result.scanResult != ScanResultValue.eligible ||
        result.eligibleOfferCount <= 0 ||
        isOffersLoading.value) {
      return;
    }

    isOffersLoading.value = true;
    offersLoadFailed.value = false;
    try {
      final offers = await repository.getEligibleOffers(result.scanPublicId);
      eligibleOffers.assignAll(offers);
    } on NormalizedApiError {
      offersLoadFailed.value = true;
    } catch (_) {
      offersLoadFailed.value = true;
    } finally {
      isOffersLoading.value = false;
    }
  }

  void openEligibleOfferSelection() {
    final result = verificationResult.value;
    final branch = scannerContext.value?.branch;
    if (result == null ||
        branch == null ||
        result.scanResult != ScanResultValue.eligible ||
        eligibleOffers.isEmpty) {
      return;
    }

    // Only the safe verification result, branch context, and eligible offers
    // cross into the redemption flow. Signed QR tokens and scanner challenges
    // have already been cleared and are never passed as route arguments.
    Get.toNamed<void>(
      AppRoutes.eligibleOffersFor(result.scanPublicId),
      arguments: RedemptionFlowContext(
        verification: result,
        branch: branch,
        offers: List<OfferDetails>.unmodifiable(eligibleOffers),
      ),
    );
  }

  Future<void> rescan() async {
    await scannerAdapter.cancel();
    await prepareFlow();
  }

  void finish() {
    _clearTransientQrState();
    unawaited(scannerAdapter.cancel());
    Get.back<void>();
  }

  Future<void> _createChallenge(PartnerBranchData branch) async {
    stage.value = QrScannerFlowStage.creatingChallenge;
    final challenge = await repository.createQrChallenge(
      ScannerChallengeRequest(branchPublicId: branch.publicId),
    );
    _challenge = challenge;
    stage.value = QrScannerFlowStage.readyToScan;
  }

  void _setApiFailure(NormalizedApiError error) {
    stage.value = error.statusCode == 403
        ? QrScannerFlowStage.permissionDenied
        : QrScannerFlowStage.serverError;
  }

  void _clearTransientQrState() {
    _signedQrToken = null;
    _challenge = null;
  }
}
