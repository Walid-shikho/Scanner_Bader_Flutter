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
import '../../../../core/widgets/bader_icon_button.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/partner_offers_controller.dart';
import '../widgets/partner_offer_management_sections.dart';

class PartnerOffersView extends GetView<PartnerOffersController> {
  const PartnerOffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(
              title: 'partner_offers'.tr,
              trailing: BaderIconButton(
                icon: 'assets/icons/plus.png',
                tooltip: 'create_offer'.tr,
                onPressed: controller.openCreate,
              ),
            ),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 760,
                padding: EdgeInsets.zero,
                child: Obx(() {
                  final state = controller.state.value;
                  final searchErrorKey = controller.searchErrorKey.value;
                  final pagination = controller.pagination;
                  final loadingMore = controller.isLoadingMore.value;
                  if (state == PartnerOffersState.loading &&
                      controller.offers.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (state == PartnerOffersState.permissionDenied) {
                    return AppEmptyState(
                      title: 'permission_denied'.tr,
                      message: 'partner_offers_permission_denied'.tr,
                    );
                  }
                  if (state == PartnerOffersState.error) {
                    return AppEmptyState(
                      title: 'server_error'.tr,
                      message: 'partner_offers_load_error'.tr,
                      actionLabel: 'retry'.tr,
                      onAction: controller.refresh,
                    );
                  }

                  return RefreshIndicator.adaptive(
                    onRefresh: controller.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.md,
                        bottom: AppSpacing.pageBottom,
                      ),
                      children: [
                        AppSearchField(
                          controller: controller.searchController,
                          hint: 'search_partner_offers'.tr,
                          readOnly: false,
                          showFilter: false,
                          onSubmitted: controller.submitSearch,
                        ),
                        if (searchErrorKey != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            searchErrorKey.tr,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        if (controller.offers.isEmpty)
                          AppEmptyState(
                            title: 'partner_offers_empty'.tr,
                            message: 'partner_offers_empty_message'.tr,
                            actionLabel: 'create_offer'.tr,
                            onAction: controller.openCreate,
                          )
                        else
                          ...controller.offers.map(
                            (offer) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: PartnerOfferCard(
                                offer: offer,
                                onTap: () => controller.openDetails(offer),
                              ),
                            ),
                          ),
                        if (pagination?.hasMore == true) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AppPrimaryButton(
                            label: 'load_more'.tr,
                            isLoading: loadingMore,
                            onPressed: loadingMore ? null : controller.loadMore,
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
