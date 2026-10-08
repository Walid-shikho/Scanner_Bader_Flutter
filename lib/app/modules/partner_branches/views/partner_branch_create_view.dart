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
import '../../../../core/widgets/bader_dropdown.dart';
import '../../../../core/widgets/bader_fields.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../../models/scanner_partner_models.dart';
import '../controllers/partner_branch_create_controller.dart';

class PartnerBranchCreateView extends GetView<PartnerBranchCreateController> {
  const PartnerBranchCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      resizeToAvoidBottomInset: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'create_branch'.tr),
            Expanded(
              child: Obx(() {
                if (controller.state.value ==
                    PartnerBranchCreateState.loadingTaxonomy) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }
                if (controller.state.value == PartnerBranchCreateState.error) {
                  return AppEmptyState(
                    title: 'error'.tr,
                    message: 'branch_taxonomy_load_error'.tr,
                    actionLabel: 'retry'.tr,
                    onAction: controller.loadTaxonomy,
                  );
                }
                return _CreateBranchForm(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateBranchForm extends StatelessWidget {
  const _CreateBranchForm({required this.controller});

  final PartnerBranchCreateController controller;

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
            if (!controller.productionTaxonomyReady)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: BaderFormSurface(
                  backgroundColor: AppColors.warningSoft,
                  child: Text(
                    'branch_taxonomy_mock_notice'.tr,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            BaderFormSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'branch_details_section'.tr,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                    validator: (value) => controller.validateRequired(
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
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BaderFormSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'branch_location_section'.tr,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Obx(
                    () => BaderDropdownFormField<String>(
                      key: ValueKey(controller.selectedProvincePublicId.value),
                      initialValue: controller.selectedProvincePublicId.value,
                      items: controller.provinces
                          .map(
                            (item) => BaderDropdownItem<String>(
                              value: item.publicId,
                              label: _taxonomyLabel(context, item),
                            ),
                          )
                          .toList(growable: false),
                      decoration: InputDecoration(labelText: 'province'.tr),
                      validator: controller.validateProvince,
                      onChanged: controller.selectProvince,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(
                    () => BaderDropdownFormField<String>(
                      key: ValueKey(controller.selectedCityPublicId.value),
                      initialValue: controller.selectedCityPublicId.value,
                      items: controller.cities
                          .map(
                            (item) => BaderDropdownItem<String>(
                              value: item.publicId,
                              label: _taxonomyLabel(context, item),
                            ),
                          )
                          .toList(growable: false),
                      decoration: InputDecoration(labelText: 'city'.tr),
                      validator: controller.validateCity,
                      onChanged: controller.selectCity,
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
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => AppPrimaryButton(
                label: 'create_branch'.tr,
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

  String _taxonomyLabel(BuildContext context, TaxonomyRef item) {
    final language = Localizations.localeOf(context).languageCode;
    return switch (language) {
      'ar' => item.name.ar,
      'de' => item.name.de ?? item.name.en ?? item.name.ar,
      _ => item.name.en ?? item.name.ar,
    };
  }
}
