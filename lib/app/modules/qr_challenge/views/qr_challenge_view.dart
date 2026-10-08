import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/qr_challenge_controller.dart';
import '../widgets/qr_scan_flow_sections.dart';

class QrChallengeView extends GetView<QrChallengeController> {
  const QrChallengeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(
              title: 'scan_qr'.tr,
              onBack: controller.finish,
            ),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 720,
                padding: EdgeInsets.zero,
                child: Obx(() {
                  final stage = controller.stage.value;
                  final scannerContext = controller.scannerContext.value;
                  final verificationResult = controller.verificationResult.value;

                  return switch (stage) {
                    QrScannerFlowStage.loadingContext => QrFlowProgress(
                        title: 'preparing_scanner'.tr,
                        message: 'preparing_scanner_message'.tr,
                      ),
                    QrScannerFlowStage.branchRequired =>
                      QrBranchRequiredContent(
                        branches: controller.branches,
                        isSelecting: controller.isSelectingBranch.value,
                        onSelect: controller.selectBranch,
                      ),
                    QrScannerFlowStage.deviceUnavailable => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: AppEmptyState(
                          icon: 'assets/icons/shield-lock.png',
                          title: 'scanner_device_unavailable'.tr,
                          message: 'scanner_device_required_message'.tr,
                          actionLabel: 'retry'.tr,
                          onAction: controller.prepareFlow,
                        ),
                      ),
                    QrScannerFlowStage.creatingChallenge => QrFlowProgress(
                        title: 'preparing_secure_scan'.tr,
                        message: 'preparing_secure_scan_message'.tr,
                      ),
                    QrScannerFlowStage.readyToScan => scannerContext == null
                        ? QrFlowProgress(
                            title: 'preparing_scanner'.tr,
                            message: 'preparing_scanner_message'.tr,
                          )
                        : QrReadyToScanContent(
                            contextData: scannerContext,
                            onScan: controller.scanAndVerify,
                        demoScenarios: controller.isOfflineDemoScanner ? controller.demoScenarios : null,
                        selectedDemoScenario: controller.isOfflineDemoScanner ? controller.selectedDemoScenario : null,
                        onDemoScenarioSelected: controller.selectDemoScenario,
                      ),
                    QrScannerFlowStage.scanning => QrFlowProgress(
                        title: 'scanning_qr'.tr,
                        message: 'scanning_qr_message'.tr,
                        showScannerFrame: true,
                      ),
                    QrScannerFlowStage.verifying => QrFlowProgress(
                        title: 'verifying_qr'.tr,
                        message: 'verifying_qr_message'.tr,
                        showScannerFrame: true,
                      ),
                    QrScannerFlowStage.result => verificationResult == null
                        ? QrFlowProgress(
                            title: 'verifying_qr'.tr,
                            message: 'verifying_qr_message'.tr,
                          )
                        : QrVerificationResultContent(
                            result: verificationResult,
                            offers: controller.eligibleOffers,
                        isOffersLoading: controller.isOffersLoading.value,
                        offersLoadFailed: controller.offersLoadFailed.value,
                        onRetryOffers: controller.loadEligibleOffers,
                        onOpenOffers: controller.openEligibleOfferSelection,
                        onRescan: controller.rescan,
                        onFinish: controller.finish,
                      ),
                    QrScannerFlowStage.permissionDenied => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: AppEmptyState(
                          icon: 'assets/icons/shield-lock.png',
                          title: 'permission_denied'.tr,
                          message: 'scanner_permission_denied_message'.tr,
                          actionLabel: 'retry'.tr,
                          onAction: controller.prepareFlow,
                        ),
                      ),
                    QrScannerFlowStage.serverError => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: AppEmptyState(
                          title: 'server_error'.tr,
                          message: 'scanner_flow_server_error_message'.tr,
                          actionLabel: 'retry'.tr,
                          onAction: controller.prepareFlow,
                        ),
                      ),
                  };
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
