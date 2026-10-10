import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../../routes/app_routes.dart';
import '../controllers/redemption_receipt_controller.dart';
import '../widgets/redemption_sections.dart';

class RedemptionReceiptView extends GetView<RedemptionReceiptController> {
  const RedemptionReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = controller.receiptArgs;
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'redemption_receipt'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 720,
                padding: EdgeInsets.zero,
                child: args == null
                    ? Padding(
                        padding: context.responsive.pageInsets(
                          top: AppSpacing.xl,
                          bottom: AppSpacing.pageBottom,
                        ),
                        child: AppEmptyState(
                          title: 'redemption_receipt_missing'.tr,
                          message: 'redemption_receipt_missing'.tr,
                        ),
                      )
                    : ListView(
                        padding: context.responsive.pageInsets(
                          top: AppSpacing.md,
                          bottom: AppSpacing.pageBottom,
                        ),
                        children: [
                          RedemptionReceiptSurface(
                            receipt: args.receipt,
                            offer: args.offer,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppPrimaryButton(
                            label: 'redemption_history'.tr,
                            onPressed: () => Get.offNamed<void>(
                              AppRoutes.redemptions,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
