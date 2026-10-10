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
import '../../../../core/widgets/bader_fields.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/partner_offer_disable_controller.dart';
import '../widgets/partner_offer_management_sections.dart';

class PartnerOfferDisableView extends GetView<PartnerOfferDisableController> {
  const PartnerOfferDisableView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      resizeToAvoidBottomInset: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'disable_offer'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 680,
                padding: context.responsive.pageInsets(
                  top: AppSpacing.md,
                  bottom: 0,
                ),
                child: Obx(() {
                  final offer = controller.offer.value;
                  if (offer == null) {
                    return AppEmptyState(
                      title: 'offer_not_found'.tr,
                      message: 'offer_details_context_missing'.tr,
                    );
                  }
                  return Form(
                    key: controller.formKey,
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.pageBottom,
                      ),
                      children: [
                        BaderFormSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'disable_offer_confirmation_title'.tr,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              PartnerOfferInfoRow(
                                label: 'offer_name_ar'.tr,
                                value: offer.titleAr,
                              ),
                              PartnerOfferInfoRow(
                                label: 'offer_current_status'.tr,
                                value: offer.status,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              BaderTextFormField(
                                controller: controller.reasonController,
                                minLines: 3,
                                maxLines: 5,
                                maxLength: 1000,
                                decoration:
                                    InputDecoration(labelText: 'disable_reason'.tr),
                                validator: controller.validateReason,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppPrimaryButton(
                          label: 'disable_offer'.tr,
                          backgroundColor: AppColors.danger,
                          isLoading: controller.isSubmitting.value,
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.disable,
                        ),
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
