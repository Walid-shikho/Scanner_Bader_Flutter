import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
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
import '../controllers/redemption_reverse_controller.dart';

class RedemptionReverseView extends GetView<RedemptionReverseController> {
  const RedemptionReverseView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'reverse_redemption'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 720,
                padding: EdgeInsets.zero,
                child: Obx(() {
                  final state = controller.state.value;
                  final validationMessageKey = controller.validationMessageKey.value;
                  if (state == RedemptionReverseState.permissionDenied) {
                    return Padding(
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.xl,
                        bottom: AppSpacing.pageBottom,
                      ),
                      child: AppEmptyState(
                        title: 'permission_denied'.tr,
                        message: 'reverse_permission_denied'.tr,
                      ),
                    );
                  }
                  if (state == RedemptionReverseState.stepUpBlocked) {
                    return Padding(
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.xl,
                        bottom: AppSpacing.pageBottom,
                      ),
                      child: AppEmptyState(
                        icon: 'assets/icons/shield-lock.png',
                        title: 'step_up_required'.tr,
                        message: 'step_up_contract_blocked'.tr,
                      ),
                    );
                  }

                  if (state == RedemptionReverseState.stepUpDenied) {
                    return Padding(
                      padding: context.responsive.pageInsets(
                        top: AppSpacing.xl,
                        bottom: AppSpacing.pageBottom,
                      ),
                      child: AppEmptyState(
                        icon: 'assets/icons/shield-lock.png',
                        title: 'step_up_required'.tr,
                        message: 'step_up_denied'.tr,
                      ),
                    );
                  }

                  return ListView(
                    padding: context.responsive.pageInsets(
                      top: AppSpacing.md,
                      bottom: AppSpacing.pageBottom,
                    ),
                    children: [
                      BaderFormSurface(
                        elevated: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'reverse_reason'.tr,
                              style: AppTextStyles.sectionTitle.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'reverse_step_up_hint'.tr,
                              style: AppTextStyles.small.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            BaderTextField(
                              controller: controller.reasonController,
                              maxLength: 1000,
                              minLines: 4,
                              maxLines: 6,
                              decoration: InputDecoration(
                                labelText: 'reverse_reason'.tr,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (validationMessageKey != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          validationMessageKey.tr,
                          style: AppTextStyles.small.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      if (state == RedemptionReverseState.error) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'reverse_redemption_error'.tr,
                          style: AppTextStyles.small.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      AppPrimaryButton(
                        label: 'reverse_redemption'.tr,
                        backgroundColor: AppColors.danger,
                        isLoading:
                            state == RedemptionReverseState.submitting,
                        onPressed: state == RedemptionReverseState.submitting
                            ? null
                            : () => _confirmReverse(context),
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

  Future<void> _confirmReverse(BuildContext context) async {
    if (!controller.validate()) return;
    final confirmed = await BaderAdaptiveDialog.show<bool>(
      context: context,
      title: 'reverse_redemption'.tr,
      content: Text(
        'reverse_confirmation_message'.tr,
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
          isDestructive: true,
        ),
      ],
    );
    if (confirmed == true) {
      await controller.execute();
    }
  }
}
