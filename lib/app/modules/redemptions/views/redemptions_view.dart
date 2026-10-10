import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/redemptions_controller.dart';
import '../widgets/redemption_sections.dart';

class RedemptionsView extends GetView<RedemptionsController> {
  const RedemptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'redemption_history'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 720,
                padding: EdgeInsets.zero,
                child: Obx(() {
                  final state = controller.state.value;
                  if (state == RedemptionHistoryState.loading) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (state == RedemptionHistoryState.permissionDenied) {
                    return Padding(
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.xl,
                        bottom: AppSpacing.pageBottom,
                      ),
                      child: AppEmptyState(
                        title: 'permission_denied'.tr,
                        message: 'redemption_history_permission_denied'.tr,
                      ),
                    );
                  }
                  if (state == RedemptionHistoryState.error) {
                    return Padding(
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.xl,
                        bottom: AppSpacing.pageBottom,
                      ),
                      child: AppEmptyState(
                        title: 'server_error'.tr,
                        message: 'redemption_history_load_error'.tr,
                        actionLabel: 'retry'.tr,
                        onAction: controller.refresh,
                      ),
                    );
                  }

                  return RefreshIndicator.adaptive(
                    onRefresh: controller.refresh,
                    child: ListView(
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.md,
                        bottom: AppSpacing.pageBottom,
                      ),
                      children: [
                        AppSearchField(
                          controller: controller.searchController,
                          hint: 'search_redemptions'.tr,
                          readOnly: false,
                          showFilter: false,
                          onSubmitted: controller.submitSearch,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (controller.items.isEmpty)
                          AppEmptyState(
                            title: 'no_redemptions_today'.tr,
                            message: 'no_redemptions_today_message'.tr,
                          )
                        else
                          ...controller.items.map(
                            (receipt) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: RedemptionHistoryCard(
                                receipt: receipt,
                                onTap: () => controller.openDetails(receipt),
                              ),
                            ),
                          ),
                        if (controller.pagination?.hasMore == true) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AppPrimaryButton(
                            label: 'load_more'.tr,
                            isLoading: controller.isLoadingMore.value,
                            onPressed: controller.isLoadingMore.value
                                ? null
                                : () => controller.loadMore(),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
