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
import '../controllers/partner_branch_edit_controller.dart';

class PartnerBranchEditView extends GetView<PartnerBranchEditController> {
  const PartnerBranchEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      resizeToAvoidBottomInset: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'edit_branch'.tr),
            Expanded(
              child: Obx(() {
                final state = controller.state.value;
                if (state == PartnerBranchEditState.loading) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }
                if (state == PartnerBranchEditState.permissionDenied) {
                  return AppEmptyState(
                    title: 'permission_denied'.tr,
                    message: 'branch_update_permission_denied'.tr,
                  );
                }
                if (state == PartnerBranchEditState.notFound) {
                  return AppEmptyState(
                    title: 'error'.tr,
                    message: 'branch_not_found'.tr,
                  );
                }
                if (state == PartnerBranchEditState.error) {
                  return AppEmptyState(
                    title: 'error'.tr,
                    message: 'branch_load_error'.tr,
                    actionLabel: 'retry'.tr,
                    onAction: controller.load,
                  );
                }
                if (state == PartnerBranchEditState.conflict) {
                  return ResponsiveContent(
                    maxWidth: 620,
                    padding: context.responsive.pageInsets(
                      top: AppSpacing.xl,
                      bottom: AppSpacing.xxl,
                    ),
                    child: BaderFormSurface(
                      backgroundColor: AppColors.warningSoft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'branch_conflict_title'.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'branch_conflict_message'.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppPrimaryButton(
                            label: 'reload_and_retry'.tr,
                            onPressed: controller.reloadForRetry,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _EditBranchForm(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditBranchForm extends StatelessWidget {
  const _EditBranchForm({required this.controller});

  final PartnerBranchEditController controller;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      maxWidth: 720,
      padding: context.responsive.pageInsets(
        top: AppSpacing.sm,
        bottom: AppSpacing.xxl,
      ),
      child: Form(
        key: controller.formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            BaderFormSurface(
              child: Column(
                children: [
                  BaderTextFormField(
                    controller: controller.nameController,
                    maxLength: 160,
                    decoration: InputDecoration(labelText: 'branch_name'.tr),
                    validator: (value) => controller.validateRequired(
                      value,
                      'branch_name',
                      160,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BaderTextFormField(
                    controller: controller.addressController,
                    maxLength: 500,
                    decoration: InputDecoration(labelText: 'branch_address'.tr),
                    validator: (value) => controller.validateOptional(
                      value,
                      'branch_address',
                      500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BaderTextFormField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 20,
                    decoration: InputDecoration(
                      labelText: 'branch_phone'.tr,
                      helperText: 'optional'.tr,
                    ),
                    validator: (value) => controller.validateOptional(
                      value,
                      'branch_phone',
                      20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: BaderTextFormField(
                          controller: controller.latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'latitude'.tr,
                            helperText: 'optional'.tr,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: BaderTextFormField(
                          controller: controller.longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'longitude'.tr,
                            helperText: 'optional'.tr,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'optimistic_concurrency_hint'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => AppPrimaryButton(
                label: 'save_changes'.tr,
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
  }
}
