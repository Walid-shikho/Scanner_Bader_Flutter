import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_icon_button.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../partner/widgets/partner_management_sections.dart';
import '../controllers/partner_branches_controller.dart';

class PartnerBranchesView extends GetView<PartnerBranchesController> {
  const PartnerBranchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(
              title: 'partner_branches'.tr,
              trailing: BaderIconButton(
                icon: 'assets/icons/plus.png',
                tooltip: 'create_branch'.tr,
                onPressed: controller.openCreate,
              ),
            ),
            Expanded(
              child: Obx(() {
                final state = controller.state.value;
                if (state == PartnerBranchesState.loading &&
                    controller.branches.isEmpty) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }
                if (state == PartnerBranchesState.permissionDenied) {
                  return AppEmptyState(
                    title: 'permission_denied'.tr,
                    message: 'partner_branches_permission_denied'.tr,
                  );
                }
                if (state == PartnerBranchesState.error) {
                  return AppEmptyState(
                    title: 'error'.tr,
                    message: 'partner_branches_load_error'.tr,
                    actionLabel: 'retry'.tr,
                    onAction: controller.load,
                  );
                }
                if (controller.branches.isEmpty) {
                  return AppEmptyState(
                    title: 'no_branches'.tr,
                    message: 'no_branches_message'.tr,
                    actionLabel: 'create_branch'.tr,
                    onAction: controller.openCreate,
                  );
                }
                return RefreshIndicator.adaptive(
                  onRefresh: controller.refreshBranches,
                  child: ResponsiveContent(
                    maxWidth: 760,
                    padding: context.responsive.pageInsets(
                      top: AppSpacing.sm,
                      bottom: 0,
                    ),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.pageBottom,
                      ),
                      itemCount: controller.branches.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final branch = controller.branches[index];
                        return PartnerBranchCard(
                          branch: branch,
                          onEdit: () => controller.openEdit(branch),
                        );
                      },
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
