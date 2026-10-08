import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../redemptions/widgets/redemption_sections.dart';
import '../controllers/eligible_offers_controller.dart';

class EligibleOffersView extends GetView<EligibleOffersController> {
  const EligibleOffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'eligible_offer_selection'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 720,
                padding: EdgeInsets.zero,
                child: Obx(() {
                  return switch (controller.state.value) {
                    EligibleOffersState.loading => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    EligibleOffersState.missingContext => Padding(
                        padding: context.responsive.pageInsets(
                          top: AppSpacing.xl,
                          bottom: AppSpacing.huge,
                        ),
                        child: AppEmptyState(
                          title: 'redemption_context_missing'.tr,
                          message: 'redemption_context_missing_message'.tr,
                        ),
                      ),
                    EligibleOffersState.error => Padding(
                        padding: context.responsive.pageInsets(
                          top: AppSpacing.xl,
                          bottom: AppSpacing.huge,
                        ),
                        child: AppEmptyState(
                          title: 'server_error'.tr,
                          message: 'eligible_offers_load_error'.tr,
                          actionLabel: 'retry'.tr,
                          onAction: controller.retry,
                        ),
                      ),
                    EligibleOffersState.loaded => controller.offers.isEmpty
                        ? Padding(
                            padding: context.responsive.pageInsets(
                              top: AppSpacing.xl,
                              bottom: AppSpacing.huge,
                            ),
                            child: AppEmptyState(
                              title: 'no_eligible_offers'.tr,
                              message: 'no_eligible_offers'.tr,
                            ),
                          )
                        : ListView.separated(
                            padding: context.responsive.pageInsets(
                              top: AppSpacing.md,
                              bottom: AppSpacing.huge,
                            ),
                            itemCount: controller.offers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final offer = controller.offers[index];
                              return RedemptionOfferCard(
                                offer: offer,
                                commandKind: controller.commandFor(offer),
                                onSelect: controller.canSelect(offer)
                                    ? () => controller.selectOffer(offer)
                                    : null,
                              );
                            },
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
