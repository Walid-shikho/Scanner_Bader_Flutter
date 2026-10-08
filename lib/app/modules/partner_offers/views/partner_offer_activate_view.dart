import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/partner_offer_activate_controller.dart';
import '../widgets/partner_offer_management_sections.dart';

class PartnerOfferActivateView extends GetView<PartnerOfferActivateController> {
  const PartnerOfferActivateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'activate_offer'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 680,
                padding: context.responsive.pageInsets(
                  top: AppSpacing.md,
                  bottom: AppSpacing.huge,
                ),
                child: Obx(() {
                  final offer = controller.offer.value;
                  if (offer == null) {
                    return AppEmptyState(
                      title: 'offer_not_found'.tr,
                      message: 'offer_details_context_missing'.tr,
                    );
                  }
                  return ListView(
                    children: [
                      BaderFormSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'activate_offer_confirmation_title'.tr,
                              style: AppTextStyles.sectionTitle.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'activate_offer_confirmation_message'.tr,
                              style: AppTextStyles.body.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PartnerOfferInfoRow(
                              label: 'offer_name_ar'.tr,
                              value: offer.titleAr,
                            ),
                            PartnerOfferInfoRow(
                              label: 'offer_current_status'.tr,
                              value: offer.status,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppPrimaryButton(
                        label: 'activate_offer'.tr,
                        isLoading: controller.isSubmitting.value,
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.activate,
                      ),
                    ],
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
