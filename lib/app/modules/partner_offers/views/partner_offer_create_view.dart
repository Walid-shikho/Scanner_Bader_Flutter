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
import '../../../../core/widgets/bader_filter_chip.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../../models/scanner_partner_models.dart';
import '../controllers/partner_offer_create_controller.dart';
import '../widgets/partner_offer_management_sections.dart';

class PartnerOfferCreateView extends GetView<PartnerOfferCreateController> {
  const PartnerOfferCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      resizeToAvoidBottomInset: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'create_offer'.tr),
            Expanded(
              child: Obx(() {
                final state = controller.state.value;
                if (state == PartnerOfferCreateState.loading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (state == PartnerOfferCreateState.permissionDenied) {
                  return AppEmptyState(
                    title: 'permission_denied'.tr,
                    message: 'offer_create_permission_denied'.tr,
                  );
                }
                if (state == PartnerOfferCreateState.error) {
                  return AppEmptyState(
                    title: 'server_error'.tr,
                    message: 'offer_dependencies_load_error'.tr,
                    actionLabel: 'retry'.tr,
                    onAction: controller.loadDependencies,
                  );
                }
                return _OfferCreateForm(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferCreateForm extends StatelessWidget {
  const _OfferCreateForm({required this.controller});

  final PartnerOfferCreateController controller;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return ResponsiveContent(
      maxWidth: 760,
      padding: context.responsive.pageInsets(
        top: AppSpacing.sm,
      ),
      child: Form(
        key: controller.formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (!controller.productionCardTaxonomyReady) ...[
              BaderFormSurface(
                backgroundColor: AppColors.warningSoft,
                child: Text(
                  'offer_card_type_mock_notice'.tr,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _LocalizedOfferSurface(
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
            _LocalizedOfferSurface(
              title: 'offer_description_section'.tr,
              arController: controller.descriptionArController,
              enController: controller.descriptionEnController,
              deController: controller.descriptionDeController,
              arLabel: 'offer_description_ar'.tr,
              enLabel: 'offer_description_en'.tr,
              deLabel: 'offer_description_de'.tr,
              arValidator: (value) => controller.validateArabicRequired(
                value,
                'offer_description_ar',
              ),
              optionalValidator: controller.validateOptionalLocalized,
              maxLines: 4,
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
                  const SizedBox(height: AppSpacing.lg),
                  Obx(
                    () => BaderDropdownFormField<PartnerOfferType>(
                      initialValue: controller.offerType.value,
                      decoration: InputDecoration(labelText: 'offer_type'.tr),
                      items: PartnerOfferType.values
                          .map(
                            (type) => BaderDropdownItem<PartnerOfferType>(
                              value: type,
                              label: _offerTypeLabel(type),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: controller.setOfferType,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BaderTextFormField(
                    controller: controller.valueController,
                    decoration: InputDecoration(
                      labelText: 'offer_value'.tr,
                      helperText: 'offer_contract_optional_hint'.tr,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: controller.validateValue,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BaderTextFormField(
                    controller: controller.pointsCostController,
                    decoration: InputDecoration(
                      labelText: 'offer_points_cost_label'.tr,
                      helperText: 'offer_contract_optional_hint'.tr,
                    ),
                    keyboardType: TextInputType.number,
                    validator: controller.validatePointsCost,
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
                    'offer_schedule_section'.tr,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'offer_branches'.tr,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'offer_branch_selection_hint'.tr,
                    style: AppTextStyles.small.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(() {
                    final branches =
                        controller.branches.toList(growable: false);
                    final selectedBranchPublicIds =
                        controller.selectedBranchPublicIds.toSet();

                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: branches.map((branch) {
                        final englishName = branch.nameEn?.trim();
                        final name = locale == 'ar'
                            ? branch.nameAr
                            : (englishName != null && englishName.isNotEmpty)
                                ? englishName
                                : branch.nameAr;
                        return BaderFilterChip(
                          selected: selectedBranchPublicIds.contains(
                              branch.publicId,
                            ),
                          label: name,
                          onSelected: (selected) =>
                              controller.toggleBranch(branch.publicId, selected),
                        );
                      }).toList(growable: false),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Obx(() {
              final cardTypes = controller.cardTypes.toList(growable: false);
              final selectedCardTypePublicIds =
                  controller.selectedCardTypePublicIds.toSet();

              return PartnerOfferTaxonomyMultiSelect(
                title: 'offer_card_types'.tr,
                hint: 'offer_card_type_selection_hint'.tr,
                items: cardTypes,
                selectedPublicIds: selectedCardTypePublicIds,
                onToggle: controller.toggleCardType,
              );
            }),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => AppPrimaryButton(
                label: 'create_offer_submit'.tr,
                isLoading: controller.isSubmitting.value,
                onPressed:
                    controller.isSubmitting.value ? null : controller.submit,
              ),
            ),

            SizedBox(height: 80,),
          ],
        ),
      ),
    );
  }

  String _offerTypeLabel(PartnerOfferType type) {
    return switch (type) {
      PartnerOfferType.free => 'offer_type_free'.tr,
      PartnerOfferType.percentage => 'offer_type_percentage'.tr,
      PartnerOfferType.fixed => 'offer_type_fixed'.tr,
      PartnerOfferType.points => 'offer_type_points'.tr,
    };
  }
}

class _LocalizedOfferSurface extends StatelessWidget {
  const _LocalizedOfferSurface({
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
