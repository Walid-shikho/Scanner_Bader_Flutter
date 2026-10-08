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
import '../controllers/partner_offer_edit_controller.dart';
import '../widgets/partner_offer_management_sections.dart';

class PartnerOfferEditView extends GetView<PartnerOfferEditController> {
  const PartnerOfferEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      resizeToAvoidBottomInset: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'edit_offer'.tr),
            Expanded(
              child: Obx(() {
                final state = controller.state.value;
                if (state == PartnerOfferEditState.loading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (state == PartnerOfferEditState.permissionDenied) {
                  return AppEmptyState(
                    title: 'permission_denied'.tr,
                    message: 'offer_edit_permission_denied'.tr,
                  );
                }
                if (state == PartnerOfferEditState.notFound) {
                  return AppEmptyState(
                    title: 'offer_not_found'.tr,
                    message: 'offer_not_found_message'.tr,
                  );
                }
                if (state == PartnerOfferEditState.error) {
                  return AppEmptyState(
                    title: 'server_error'.tr,
                    message: 'offer_edit_load_error'.tr,
                    actionLabel: 'retry'.tr,
                    onAction: controller.load,
                  );
                }
                if (state == PartnerOfferEditState.conflict) {
                  return Padding(
                    padding: context.responsive.pageInsets(
                      top: AppSpacing.xl,
                      bottom: AppSpacing.huge,
                    ),
                    child: AppEmptyState(
                      title: 'offer_conflict_title'.tr,
                      message: 'offer_conflict_message'.tr,
                      actionLabel: 'reload_and_retry'.tr,
                      onAction: controller.reloadForRetry,
                    ),
                  );
                }
                return _OfferEditForm(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferEditForm extends StatelessWidget {
  const _OfferEditForm({required this.controller});

  final PartnerOfferEditController controller;

  @override
  Widget build(BuildContext context) {
    final offer = controller.offer.value;
    return ResponsiveContent(
      maxWidth: 760,
      padding: context.responsive.pageInsets(
        top: AppSpacing.sm,
        bottom: AppSpacing.huge,
      ),
      child: Form(
        key: controller.formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            BaderFormSurface(
              backgroundColor: AppColors.warningSoft,
              child: Text(
                'offer_etag_hint'.tr,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BaderFormSurface(
              child: Text(
                'offer_german_roundtrip_notice'.tr,
                style: AppTextStyles.small.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BaderFormSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'offer_configuration_section'.tr,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PartnerOfferInfoRow(
                    label: 'offer_type'.tr,
                    value: _offerTypeLabel(offer?.discountType ?? ''),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'offer_type_not_editable'.tr,
                    style: AppTextStyles.small.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _LocalizedEditSurface(
              title: 'offer_name_section'.tr,
              arController: controller.nameArController,
              enController: controller.nameEnController,
              deController: controller.nameDeController,
              arLabel: 'offer_name_ar'.tr,
              enLabel: 'offer_name_en'.tr,
              deLabel: 'offer_name_de'.tr,
              arValidator: (value) => controller.validateArabicRequired(
                value,
                'offer_name_ar',
              ),
              optionalValidator: controller.validateOptionalLocalized,
            ),
            const SizedBox(height: AppSpacing.md),
            _LocalizedEditSurface(
              title: 'offer_description_section'.tr,
              arController: controller.descriptionArController,
              enController: controller.descriptionEnController,
              deController: controller.descriptionDeController,
              arLabel: 'offer_description_ar'.tr,
              enLabel: 'offer_description_en'.tr,
              deLabel: 'offer_description_de'.tr,
              arValidator: (value) =>
                  controller.validateOptionalLocalized(value, 'offer_description_ar'),
              optionalValidator: controller.validateOptionalLocalized,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            BaderFormSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'offer_editable_contract_fields'.tr,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BaderTextFormField(
                    controller: controller.valueController,
                    decoration: InputDecoration(labelText: 'offer_value'.tr),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: controller.validateValue,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BaderTextFormField(
                    controller: controller.pointsCostController,
                    decoration:
                        InputDecoration(labelText: 'offer_points_cost_label'.tr),
                    keyboardType: TextInputType.number,
                    validator: controller.validatePointsCost,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BaderTextFormField(
                    controller: controller.startsAtController,
                    decoration: InputDecoration(
                      labelText: 'offer_starts_at'.tr,
                      hintText: 'offer_datetime_hint'.tr,
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: controller.validateDate,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BaderTextFormField(
                    controller: controller.endsAtController,
                    decoration: InputDecoration(
                      labelText: 'offer_ends_at'.tr,
                      hintText: 'offer_datetime_hint'.tr,
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: controller.validateDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BaderFormSurface(
              child: Text(
                'offer_targeting_not_editable'.tr,
                style: AppTextStyles.small.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => AppPrimaryButton(
                label: 'save_changes'.tr,
                isLoading: controller.isSubmitting.value,
                onPressed:
                    controller.isSubmitting.value ? null : controller.submit,
              ),
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

class _LocalizedEditSurface extends StatelessWidget {
  const _LocalizedEditSurface({
    required this.title,
    required this.arController,
    required this.enController,
    required this.deController,
    required this.arLabel,
    required this.enLabel,
    required this.deLabel,
    required this.arValidator,
    required this.optionalValidator,
    this.maxLines = 1,
  });

  final String title;
  final TextEditingController arController;
  final TextEditingController enController;
  final TextEditingController deController;
  final String arLabel;
  final String enLabel;
  final String deLabel;
  final FormFieldValidator<String> arValidator;
  final String? Function(String?, String) optionalValidator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return BaderFormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BaderTextFormField(
            controller: arController,
            maxLength: 500,
            maxLines: maxLines,
            decoration: InputDecoration(labelText: arLabel),
            validator: arValidator,
          ),
          const SizedBox(height: AppSpacing.md),
          BaderTextFormField(
            controller: enController,
            maxLength: 500,
            maxLines: maxLines,
            decoration: InputDecoration(labelText: enLabel),
            validator: (value) => optionalValidator(value, enLabel),
          ),
          const SizedBox(height: AppSpacing.md),
          BaderTextFormField(
            controller: deController,
            maxLength: 500,
            maxLines: maxLines,
            decoration: InputDecoration(labelText: deLabel),
            validator: (value) => optionalValidator(value, deLabel),
          ),
        ],
      ),
    );
  }
}
