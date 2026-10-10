import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/bader_adaptive_dialog.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../../../core/widgets/loading/bader_content_skeletons.dart';
import '../../../../core/widgets/loading/bader_shimmer.dart';
import '../../../services/partner_offline_extras_repository.dart';
import '../controllers/partner_notifications_controller.dart';
import '../widgets/partner_notification_card.dart';

class PartnerNotificationsView extends GetView<PartnerNotificationsController> {
  const PartnerNotificationsView({super.key});

  String _title(OfflinePartnerNotification item) =>
      switch (Get.locale?.languageCode) {
        'en' => item.titleEn,
        'de' => item.titleDe,
        _ => item.titleAr,
      };

  String _body(OfflinePartnerNotification item) =>
      switch (Get.locale?.languageCode) {
        'en' => item.bodyEn,
        'de' => item.bodyDe,
        _ => item.bodyAr,
      };

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      title: 'partner_notifications'.tr,
      actions: [
        // AdaptiveAppBarAction(
        //   title: 'notification_preferences'.tr,
        //   onPressed: () => _showNotificationPreferences(context),
        // ),
        AdaptiveAppBarAction(
          title: 'mark_all_read'.tr,
          onPressed: controller.markAllRead,
        ),
      ],
      body: BaderPageSafeArea(
        appBarHandled: true,
        child: ResponsiveContent(
          padding: EdgeInsets.zero,
          maxWidth: 760,
          child: Obx(() {
            final loading = controller.loading.value;
            final items = controller.notifications.toList(growable: false);

            if (loading && items.isEmpty) {
              return BaderShimmer(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: context.responsive.pageInsets(
                    top: 0,
                    bottom: AppSpacing.pageBottom,
                  ),
                  itemCount: 6,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, __) =>
                      const BaderNotificationRowSkeleton(),
                ),
              );
            }

            if (items.isEmpty) {
              return AppEmptyState(
                icon: 'assets/icons/bell-off.png',
                title: 'notifications_empty'.tr,
                message: 'notifications_empty_message'.tr,
              );
            }

            return RefreshIndicator.adaptive(
              onRefresh: controller.load,
              color: AppColors.primary,
              child: ListView.separated(
                padding: context.responsive.pageInsets(
                  top: 0,
                  bottom: AppSpacing.pageBottom,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return PartnerNotificationCard(
                    item: item,
                    title: _title(item),
                    body: _body(item),
                    onTap: () => controller.markRead(item),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _showNotificationPreferences(BuildContext context) async {
    await BaderAdaptiveDialog.show<bool>(
      context: context,
      title: 'notification_preferences'.tr,
      content: Obx(() {
        final prefs = controller.preferences.value;
        if (prefs == null) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PreferenceTile(
              label: 'notifications_in_app'.tr,
              value: prefs.inAppEnabled,
              onChanged: controller.toggleInApp,
            ),
            const SizedBox(height: AppSpacing.sm),
            _PreferenceTile(
              label: 'notifications_push'.tr,
              value: prefs.pushEnabled,
              onChanged: controller.togglePush,
            ),
          ],
        );
      }),
      actions: [
        BaderAdaptiveDialogAction<bool>(
          label: 'done'.tr,
          result: true,
          isDefault: true,
        ),
      ],
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
