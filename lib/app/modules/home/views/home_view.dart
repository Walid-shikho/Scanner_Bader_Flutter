import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_fading_header.dart';
import '../../../../core/widgets/bader_icon_button.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_dashboard_sections.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final pagePadding = responsive.horizontalPagePadding;

    return BaderPageSafeArea(
      bottom: false,
      child: RefreshIndicator.adaptive(
        onRefresh: controller.refreshDashboard,
        color: AppColors.primary,
        child: ResponsiveContent(
          maxWidth: 820,
          padding: EdgeInsets.zero,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              AppFadingHeaderSliver(
                fadeDistance: responsive.isNarrow ? 104 : 120,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    pagePadding,
                    AppSpacing.md,
                    pagePadding,
                    AppSpacing.sm,
                  ),
                  child: _ScannerHomeHeader(controller: controller),
                ),
              ),
              Obx(() {
                final state = controller.state.value;
                if (state == HomeDashboardState.loading) {
                  return SliverPadding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      pagePadding,
                      AppSpacing.md,
                      pagePadding,
                      AppSpacing.huge,
                    ),
                    sliver: const SliverToBoxAdapter(
                      child: HomeDashboardLoading(),
                    ),
                  );
                }

                if (state == HomeDashboardState.permissionDenied) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: pagePadding),
                      child: AppEmptyState(
                        icon: 'assets/icons/shield-lock.png',
                        title: 'permission_denied'.tr,
                        message: 'home_permission_denied_message'.tr,
                        actionLabel: 'retry'.tr,
                        onAction: () => controller.loadDashboard(),
                      ),
                    ),
                  );
                }

                final scannerContext = controller.scannerContext.value;
                final statistics = controller.dailyStatistics.value;
                if (state == HomeDashboardState.serverError ||
                    scannerContext == null ||
                    statistics == null) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: pagePadding),
                      child: AppEmptyState(
                        icon: 'assets/icons/file-empty.png',
                        title: 'server_error'.tr,
                        message: 'home_server_error_message'.tr,
                        actionLabel: 'retry'.tr,
                        onAction: () => controller.loadDashboard(),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    pagePadding,
                    AppSpacing.md,
                    pagePadding,
                    AppSpacing.pageBottom,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      HomePrimaryScanCta(
                        enabled: controller.canScan,
                        onScan: controller.openScan,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      HomeDailyStatistics(statistics: statistics),
                      const SizedBox(height: AppSpacing.xxl),
                      HomeRecentRedemptions(
                        redemptions:
                            controller.recentRedemptions.toList(growable: false),
                        onSeeAll: controller.openRedemptions,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      HomeQuickActions(
                        onRedemptions: controller.openRedemptions,
                        onStatistics: controller.openStatistics,
                        onSettings: controller.openSettings,
                      ),
                    ]),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

}


class _ScannerHomeHeader extends StatelessWidget {
  const _ScannerHomeHeader({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final responsive = context.responsive;
    final primary = dark ? AppColors.darkText : AppColors.textPrimary;
    final secondary =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 360 || responsive.veryLargeText;
        final greeting = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'scanner_operator_mode'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small.copyWith(
                color: secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Obx(() {
              final name =
                  controller.scannerContext.value?.partner.displayName.trim();
              return Text(
                name?.isNotEmpty == true ? (name ?? 'home'.tr) : 'home'.tr,
                maxLines: responsive.largeText ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.pageTitle.copyWith(
                  color: primary,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              );
            }),
          ],
        );

        final settings = BaderIconButton(
          icon: 'assets/icons/settings.png',
          tooltip: 'settings'.tr,
          onPressed: controller.openSettings,
        );

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              greeting,
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: settings,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: greeting),
            const SizedBox(width: AppSpacing.lg),
            settings,
          ],
        );
      },
    );
  }
}
