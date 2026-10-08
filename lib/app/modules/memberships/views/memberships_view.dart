import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/memberships_controller.dart';
import '../widgets/partner_membership_card.dart';

class MembershipsView extends GetView<MembershipsController> {
  const MembershipsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'memberships'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 760,
                padding: EdgeInsets.zero,
                child: Obx(() {
                  final state = controller.state.value;
                  if (state == MembershipsState.loading &&
                      controller.items.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (state == MembershipsState.permissionDenied) {
                    return Padding(
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.xl,
                        bottom: AppSpacing.huge,
                      ),
                      child: AppEmptyState(
                        title: 'permission_denied'.tr,
                        message: 'memberships_permission_denied'.tr,
                      ),
                    );
                  }
                  if (state == MembershipsState.error) {
                    return Padding(
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.xl,
                        bottom: AppSpacing.huge,
                      ),
                      child: AppEmptyState(
                        title: 'server_error'.tr,
                        message: 'memberships_load_error'.tr,
                        actionLabel: 'retry'.tr,
                        onAction: controller.refresh,
                      ),
                    );
                  }

                  return RefreshIndicator.adaptive(
                    onRefresh: controller.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.md,
                        bottom: AppSpacing.huge,
                      ),
                      children: [
                        const _ReadOnlyMembershipNotice(),
                        const SizedBox(height: AppSpacing.lg),
                        AppSearchField(
                          controller: controller.searchController,
                          hint: 'memberships_search_hint'.tr,
                          readOnly: false,
                          showFilter: false,
                          onSubmitted: controller.submitSearch,
                        ),
                        if (controller.searchErrorKey.value != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            controller.searchErrorKey.value!.tr,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        if (controller.items.isEmpty)
                          AppEmptyState(
                            title: 'memberships_empty'.tr,
                            message: 'memberships_empty_message'.tr,
                          )
                        else
                          ...controller.items.map(
                            (membership) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: PartnerMembershipCard(
                                membership: membership,
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

class _ReadOnlyMembershipNotice extends StatelessWidget {
  const _ReadOnlyMembershipNotice();

  @override
  Widget build(BuildContext context) {
    return BaderFormSurface(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BaderAssetIcon(
            'assets/icons/shield-lock.png',
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'memberships_read_only_title'.tr,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'memberships_read_only_message'.tr,
                  style: AppTextStyles.small.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
