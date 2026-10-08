import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/redemption_details_controller.dart';
import '../widgets/redemption_sections.dart';

class RedemptionDetailsView extends GetView<RedemptionDetailsController> {
  const RedemptionDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'redemption_details'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 720,
                padding: EdgeInsets.zero,
                child: Obx(() {
                  final receipt = controller.receipt.value;
                  return switch (controller.state.value) {
                    RedemptionDetailsState.loading => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    RedemptionDetailsState.permissionDenied => Padding(
                        padding: context.responsive.pageInsets(
                          top: AppSpacing.xl,
                          bottom: AppSpacing.huge,
                        ),
                        child: AppEmptyState(
                          title: 'permission_denied'.tr,
                          message: 'redemption_history_permission_denied'.tr,
                        ),
                      ),
                    RedemptionDetailsState.notFound => Padding(
                        padding: context.responsive.pageInsets(
                          top: AppSpacing.xl,
                          bottom: AppSpacing.huge,
                        ),
                        child: AppEmptyState(
                          title: 'redemption_not_found'.tr,
                          message: 'redemption_not_found'.tr,
                        ),
                      ),
                    RedemptionDetailsState.error => Padding(
                        padding: context.responsive.pageInsets(
                          top: AppSpacing.xl,
                          bottom: AppSpacing.huge,
                        ),
                        child: AppEmptyState(
                          title: 'server_error'.tr,
                          message: 'redemption_history_load_error'.tr,
                          actionLabel: 'retry'.tr,
                          onAction: controller.load,
                        ),
                      ),
                    RedemptionDetailsState.loaded => receipt == null
                        ? Padding(
                            padding: context.responsive.pageInsets(
                              top: AppSpacing.xl,
                              bottom: AppSpacing.huge,
                            ),
                            child: AppEmptyState(
                              title: 'redemption_not_found'.tr,
                              message: 'redemption_not_found'.tr,
                            ),
                          )
                        : ListView(
                            padding: context.responsive.pageInsets(
                              top: AppSpacing.md,
                              bottom: AppSpacing.huge,
                            ),
                            children: [
                              RedemptionReceiptSurface(receipt: receipt),
                              if (controller.canShowReverse) ...[
                                const SizedBox(height: AppSpacing.xl),
                                AppPrimaryButton(
                                  label: 'reverse_redemption'.tr,
                                  backgroundColor: AppColors.danger,
                                  onPressed: controller.openReverse,
                                ),
                              ],
                            ],
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
