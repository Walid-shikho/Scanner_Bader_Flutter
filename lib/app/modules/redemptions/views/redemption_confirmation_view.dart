import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_dialog.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_fields.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/redemption_confirmation_controller.dart';
import '../widgets/redemption_sections.dart';

class RedemptionConfirmationView
    extends GetView<RedemptionConfirmationController> {
  const RedemptionConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'redemption_confirmation'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 720,
                padding: EdgeInsets.zero,
                child: Obx(() {
                  final args = controller.args;
                  final validationMessageKey =
                      controller.validationMessageKey.value;
                  final executionErrorKey = controller.executionErrorKey.value;
                  if (args == null) {
                    return Padding(
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.xl,
                        bottom: AppSpacing.pageBottom,
                      ),
                      child: AppEmptyState(
                        title: 'redemption_context_missing'.tr,
                        message: 'redemption_context_missing_message'.tr,
                      ),
                    );
                  }

                  return ListView(
                    padding: context.responsive.pageInsets(
                      top: AppSpacing.md,
                      bottom: AppSpacing.pageBottom,
                    ),
                    children: [
                      RedemptionContextSummary(args: args),
                      const SizedBox(height: AppSpacing.md),
                      BaderFormSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'redemption_optional_invoice'.tr,
                              style: AppTextStyles.sectionTitle.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'redemption_optional_invoice_hint'.tr,
                              style: AppTextStyles.small.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'include_invoice_amount'.tr,
                                    style: AppTextStyles.bodyBold,
                                  ),
                                ),
                                Switch.adaptive(
                                  value: controller.includeInvoiceAmount.value,
                                  onChanged: controller.setIncludeInvoiceAmount,
                                ),
                              ],
                            ),
                            if (controller.includeInvoiceAmount.value) ...[
                              const SizedBox(height: AppSpacing.md),
                              BaderTextField(
                                controller: controller.invoiceAmountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[-0-9.]'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'invoice_amount'.tr,
                                  hintText: 'invoice_amount_contract_hint'.tr,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!controller.sensitiveRedemptionAllowed) ...[
                        const SizedBox(height: AppSpacing.md),
                        BaderFormSurface(
                          child: Text(
                            'sensitive_redemption_backend_guard'.tr,
                            style: AppTextStyles.small.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ],
                      if (controller.requiresPin) ...[
                        const SizedBox(height: AppSpacing.md),
                        BaderFormSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'static_qr_pin'.tr,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'static_qr_pin_hint'.tr,
                                style: AppTextStyles.small.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              BaderTextField(
                                controller: controller.staticPinController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'),
                                  ),
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'static_qr_pin'.tr,
                                  counterText: '',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!controller.staticPinContractCompatible ||
                          !controller.hasSupportedCommand) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.warningSoft,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Text(
                            !controller.hasSupportedCommand
                                ? 'redemption_mapping_unresolved'.tr
                                : 'static_pin_contract_mismatch'.tr,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      if (validationMessageKey != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          validationMessageKey.tr,
                          style: AppTextStyles.small.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (executionErrorKey != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          executionErrorKey.tr,
                          style: AppTextStyles.small.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      AppPrimaryButton(
                        label: 'confirm_redemption'.tr,
                        icon: 'assets/icons/check.png',
                        isLoading: controller.state.value ==
                            RedemptionConfirmationState.submitting,
                        onPressed: controller.canExecute
                            ? () => _showFinalConfirmation(context)
                            : null,
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

  Future<void> _showFinalConfirmation(BuildContext context) async {
    if (!controller.validate()) return;
    final confirmed = await BaderAdaptiveDialog.show<bool>(
      context: context,
      title: 'confirm_redemption'.tr,
      content: Text(
        'confirm_redemption_message'.tr,
        style: AppTextStyles.body,
      ),
      actions: [
        BaderAdaptiveDialogAction<bool>(
          label: 'cancel'.tr,
          result: false,
        ),
        BaderAdaptiveDialogAction<bool>(
          label: 'confirm'.tr,
          result: true,
          isDefault: true,
        ),
      ],
    );
    if (confirmed == true) {
      await controller.execute();
    } else {
      controller.clearStaticPin();
    }
  }
}
