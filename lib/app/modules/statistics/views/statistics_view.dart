import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_filter_chip.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../redemptions/widgets/redemption_sections.dart';
import '../controllers/statistics_controller.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'daily_statistics'.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 720,
                padding: EdgeInsets.zero,
                child: Obx(() {
                  final statistics = controller.statistics.value;
                  return switch (controller.state.value) {
                    StatisticsState.loading => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    StatisticsState.permissionDenied => Padding(
                        padding: context.responsive.pageInsets(
                          top: AppSpacing.xl,
                          bottom: AppSpacing.pageBottom,
                        ),
                        child: AppEmptyState(
                          title: 'permission_denied'.tr,
                          message: 'redemption_history_permission_denied'.tr,
                        ),
                      ),
                    StatisticsState.error => Padding(
                        padding: context.responsive.pageInsets(
                          top: AppSpacing.xl,
                          bottom: AppSpacing.pageBottom,
                        ),
                        child: AppEmptyState(
                          title: 'server_error'.tr,
                          message: 'home_server_error_message'.tr,
                          actionLabel: 'retry'.tr,
                          onAction: controller.load,
                        ),
                      ),
                    StatisticsState.loaded => statistics == null
                        ? Padding(
                            padding: context.responsive.pageInsets(
                              top: AppSpacing.xl,
                              bottom: AppSpacing.pageBottom,
                            ),
                            child: AppEmptyState(
                              title: 'server_error'.tr,
                              message: 'home_server_error_message'.tr,
                              actionLabel: 'retry'.tr,
                              onAction: controller.load,
                            ),
                          )
                        : ListView(
                            padding: context.responsive.pageInsets(
                              top: AppSpacing.md,
                              bottom: AppSpacing.pageBottom,
                            ),
                            children: [
                          BaderFormSurface(
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: <String>['daily', 'weekly', 'monthly']
                                  .map((period) => BaderFilterChip(
                                        selected: controller.period.value == period,
                                        label: 'statistics_period_$period'.tr,
                                        onSelected: (_) => controller.setPeriod(period),
                                      ))
                                  .toList(growable: false),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          DailyStatisticsSurface(
                            statistics: statistics,
                          ),
                        ],
                      ),
                  };
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
