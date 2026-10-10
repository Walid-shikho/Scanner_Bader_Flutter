import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_fields.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/partner_profile_change_controller.dart';

class PartnerProfileChangeView extends GetView<PartnerProfileChangeController> {
  const PartnerProfileChangeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      resizeToAvoidBottomInset: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'request_profile_change'.tr),
            Expanded(
              child: Obx(() {
                if (controller.state.value == PartnerProfileChangeState.loading) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }
                if (controller.state.value ==
                    PartnerProfileChangeState.permissionDenied) {
                  return AppEmptyState(
                    title: 'permission_denied'.tr,
                    message: 'profile_change_permission_denied'.tr,
                  );
                }
                if (controller.state.value == PartnerProfileChangeState.error) {
                  return AppEmptyState(
                    title: 'error'.tr,
                    message: 'partner_profile_load_error'.tr,
                    actionLabel: 'retry'.tr,
                    onAction: controller.load,
                  );
                }

                return ResponsiveContent(
                  maxWidth: 720,
                  padding: context.responsive.pageInsets(
                    top: AppSpacing.sm,
                    bottom: 0,
                  ),
                  child: Form(
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
                                'protected_fields_section'.tr,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'protected_profile_change_hint'.tr,
                                style: AppTextStyles.small.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              BaderTextFormField(
                                controller: controller.nameController,
                                maxLength: 200,
                                decoration: InputDecoration(labelText: 'partner_name'.tr),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              BaderTextFormField(
                                controller: controller.displayNameController,
                                maxLength: 200,
                                decoration: InputDecoration(labelText: 'partner_display_name'.tr),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              BaderTextFormField(
                                controller: controller.legalNameController,
                                maxLength: 200,
                                decoration: InputDecoration(labelText: 'partner_legal_name'.tr),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              BaderTextFormField(
                                controller: controller.businessRegistrationController,
                                maxLength: 200,
                                decoration: InputDecoration(labelText: 'business_registration'.tr),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: BaderTextFormField(
                                      controller: controller.latitudeController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                      decoration: InputDecoration(labelText: 'latitude'.tr),
                                      validator: controller.validateLatitude,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: BaderTextFormField(
                                      controller: controller.longitudeController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                      decoration: InputDecoration(labelText: 'longitude'.tr),
                                      validator: controller.validateLongitude,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        BaderFormSurface(
                          child: BaderTextFormField(
                            controller: controller.reasonController,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 1000,
                            decoration: InputDecoration(
                              labelText: 'profile_change_reason'.tr,
                              alignLabelWithHint: true,
                            ),
                            validator: controller.validateReason,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Obx(
                          () => AppPrimaryButton(
                            label: 'submit_profile_change'.tr,
                            isLoading: controller.isSubmitting.value,
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
