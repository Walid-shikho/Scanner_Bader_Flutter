import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/partner_offer_details_controller.dart';
import '../widgets/partner_offer_management_sections.dart';

class PartnerOfferDetailsView extends GetView<PartnerOfferDetailsController> {
  const PartnerOfferDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(
              title: 'offer_details'.tr,
              onBack: controller.close,
            ),
            Expanded(
              child: Obx(() {
                final offer = controller.offer.value;
                if (offer == null) {
                  return AppEmptyState(
                    title: 'offer_details'.tr,
                    message: 'offer_details_context_missing'.tr,
                  );
                }
                final titleEn = offer.titleEn?.trim();
                final descriptionAr = offer.descriptionAr?.trim();
                final descriptionEn = offer.descriptionEn?.trim();
                final discountValue = offer.discountValue;
                final pointsCost = offer.pointsCost;
                return ResponsiveContent(
                  maxWidth: 760,
                  padding: context.responsive.pageInsets(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.huge,
                  ),
                  child: ListView(
                    children: [
                      BaderFormSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    offer.titleAr,
                                    style: AppTextStyles.title.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                PartnerOfferStatusChip(status: offer.status),
                              ],
                            ),
                            if (titleEn != null && titleEn.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                titleEn,
                                style: AppTextStyles.small.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            PartnerOfferInfoRow(
                              label: 'offer_type'.tr,
                              value: _offerTypeLabel(offer.discountType),
                            ),
                            if (discountValue != null)
                              PartnerOfferInfoRow(
                                label: 'offer_value'.tr,
                                value: discountValue.toString(),
                              ),
                            if (pointsCost != null)
                              PartnerOfferInfoRow(
                                label: 'offer_points_cost_label'.tr,
                                value: pointsCost.toString(),
                              ),
                            PartnerOfferInfoRow(
                              label: 'offer_starts_at'.tr,
                              value: offer.startsAt.toLocal().toString(),
                            ),
                            PartnerOfferInfoRow(
                              label: 'offer_ends_at'.tr,
                              value: offer.endsAt.toLocal().toString(),
                            ),
                            PartnerOfferInfoRow(
                              label: 'offer_usage_count'.tr,
                              value: offer.successfulUsageCount.toString(),
                            ),
                          ],
                        ),
                      ),
                      if ((descriptionAr != null && descriptionAr.isNotEmpty) ||
                          (descriptionEn != null && descriptionEn.isNotEmpty)) ...[
                        const SizedBox(height: AppSpacing.md),
                        BaderFormSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'offer_description_section'.tr,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (descriptionAr != null && descriptionAr.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  descriptionAr,
                                  style: AppTextStyles.body,
                                ),
                              ],
                              if (descriptionEn != null && descriptionEn.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  descriptionEn,
                                  style: AppTextStyles.body.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      BaderFormSurface(
                        child: Text(
                          'offer_details_contract_scope_notice'.tr,
                          style: AppTextStyles.small.copyWith(
                            color:
                                Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppPrimaryButton(
                        label: 'edit_offer'.tr,
                        onPressed: controller.openEdit,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppPrimaryButton(
                        label: 'activate_offer'.tr,
                        onPressed: controller.openActivate,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppPrimaryButton(
                        label: 'disable_offer'.tr,
                        backgroundColor: AppColors.danger,
                        onPressed: controller.openDisable,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _offerTypeLabel(String raw) {
    return switch (raw) {
      'free' => 'offer_type_free'.tr,
      'percentage' => 'offer_type_percentage'.tr,
      'fixed' => 'offer_type_fixed'.tr,
      'points' => 'offer_type_points'.tr,
      _ => raw,
    };
  }
}
