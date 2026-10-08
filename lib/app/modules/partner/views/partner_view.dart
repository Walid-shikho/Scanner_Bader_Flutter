import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_fading_header.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/bader_icon_button.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/partner_controller.dart';
import '../widgets/partner_management_sections.dart';

class PartnerView extends GetView<PartnerController> {
  const PartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final horizontal = responsive.horizontalPagePadding;
    final media = MediaQuery.of(context);
    final usableHeight =
        media.size.height - media.padding.top - media.padding.bottom;
    final mosaicHeight = (usableHeight -
            (responsive.isNarrow ? 152.0 : 168.0))
        .clamp(430.0, responsive.isNarrow ? 680.0 : 620.0)
        .toDouble();
    final fillViewport = !responsive.veryLargeText && media.size.width >= 310;

    return BaderPageSafeArea(
      bottom: false,
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
                  horizontal,
                  AppSpacing.md,
                  horizontal,
                  AppSpacing.sm,
                ),
                child: _PartnerHomeHeader(controller: controller),
              ),
            ),
            SliverPadding(
              padding: EdgeInsetsDirectional.fromSTEB(
                horizontal,
                AppSpacing.lg,
                horizontal,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: AppSectionHeader(title: 'partner_workspace'.tr),
              ),
            ),
            SliverPadding(
              padding: EdgeInsetsDirectional.fromSTEB(
                horizontal,
                AppSpacing.sm,
                horizontal,
                media.padding.bottom + AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: fillViewport
                    ? SizedBox(
                        height: mosaicHeight,
                        child: _PartnerHomeMosaic(controller: controller),
                      )
                    : _PartnerHomeMosaic(controller: controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerHomeMosaic extends StatelessWidget {
  const _PartnerHomeMosaic({required this.controller});

  final PartnerController controller;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final profile = PartnerHomeMosaicTile(
      title: 'partner_profile'.tr,
      subtitle: 'partner_profile_hub_subtitle'.tr,
      icon: 'assets/icons/user.png',
      background: AppColors.primary,
      onTap: controller.openPartnerProfile,
    );
    final branches = PartnerHomeMosaicTile(
      title: 'partner_branches'.tr,
      subtitle: 'partner_branches_hub_subtitle'.tr,
      icon: 'assets/icons/map-pin.png',
      background: AppColors.secondary,
      showSubtitle: false,
      onTap: controller.openBranches,
    );
    final offers = PartnerHomeMosaicTile(
      title: 'partner_offers'.tr,
      subtitle: 'partner_offers_hub_subtitle'.tr,
      icon: 'assets/icons/stack-2.png',
      background: AppColors.primaryDark,
      showSubtitle: false,
      onTap: controller.openOffers,
    );
    final memberships = PartnerHomeMosaicTile(
      title: 'memberships'.tr,
      subtitle: 'partner_memberships_hub_subtitle'.tr,
      icon: 'assets/icons/user-check.png',
      background: Color.lerp(AppColors.secondary, Colors.white, .10)!,
      showSubtitle: false,
      onTap: controller.openMemberships,
    );
    final notifications = PartnerHomeMosaicTile(
      title: 'partner_notifications'.tr,
      subtitle: 'partner_notifications_hub_subtitle'.tr,
      icon: 'assets/icons/bell-ringing-2.png',
      background: AppColors.secondaryDark,
      showSubtitle: false,
      onTap: controller.openNotifications,
    );
    final settings = PartnerHomeMosaicTile(
      title: 'settings'.tr,
      subtitle: 'profile_settings_entry_hint'.tr,
      icon: 'assets/icons/settings.png',
      background: AppColors.primaryDeep,
      onTap: controller.openSettings,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = width < 360 ? AppSpacing.sm : AppSpacing.md;

        if (responsive.veryLargeText || width < 310) {
          final items = [
            profile,
            branches,
            offers,
            memberships,
            notifications,
            settings,
          ];
          return Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                SizedBox(height: 124, child: items[i]),
                if (i != items.length - 1) SizedBox(height: gap),
              ],
            ],
          );
        }

        if (width >= 620) {
          const baseTopHeight = 170.0;
          const baseBottomHeight = 160.0;
          final availableRowsHeight = constraints.maxHeight - gap;
          final baseRowsHeight = baseTopHeight + baseBottomHeight;
          final extraHeight = availableRowsHeight > baseRowsHeight
              ? availableRowsHeight - baseRowsHeight
              : 0.0;
          final topHeight = baseTopHeight + (extraHeight * .52);
          final bottomHeight = baseBottomHeight + (extraHeight * .48);

          return Column(
            children: [
              SizedBox(
                height: topHeight,
                child: Row(
                  children: [
                    Expanded(flex: 2, child: profile),
                    SizedBox(width: gap),
                    Expanded(child: branches),
                    SizedBox(width: gap),
                    Expanded(child: offers),
                  ],
                ),
              ),
              SizedBox(height: gap),
              SizedBox(
                height: bottomHeight,
                child: Row(
                  children: [
                    Expanded(child: memberships),
                    SizedBox(width: gap),
                    Expanded(flex: 2, child: notifications),
                    SizedBox(width: gap),
                    Expanded(child: settings),
                  ],
                ),
              ),
            ],
          );
        }

        final baseTopHeight = width < 360 ? 132.0 : 148.0;
        final baseMiddleHeight = width < 360 ? 116.0 : 128.0;
        final baseBottomHeight = width < 360 ? 112.0 : 122.0;
        final availableRowsHeight = constraints.maxHeight - (gap * 2);
        final baseRowsHeight =
            baseTopHeight + baseMiddleHeight + baseBottomHeight;
        final extraHeight = availableRowsHeight > baseRowsHeight
            ? availableRowsHeight - baseRowsHeight
            : 0.0;
        final topHeight = baseTopHeight + (extraHeight * .36);
        final middleHeight = baseMiddleHeight + (extraHeight * .34);
        final bottomHeight = baseBottomHeight + (extraHeight * .30);

        return Column(
          children: [
            SizedBox(
              height: topHeight,
              child: Row(
                children: [
                  Expanded(flex: 2, child: profile),
                  SizedBox(width: gap),
                  Expanded(child: branches),
                ],
              ),
            ),
            SizedBox(height: gap),
            SizedBox(
              height: middleHeight,
              child: Row(
                children: [
                  Expanded(child: offers),
                  SizedBox(width: gap),
                  Expanded(child: memberships),
                  SizedBox(width: gap),
                  Expanded(child: notifications),
                ],
              ),
            ),
            SizedBox(height: gap),
            SizedBox(height: bottomHeight, child: settings),
          ],
        );
      },
    );
  }
}

class _PartnerHomeHeader extends StatelessWidget {
  const _PartnerHomeHeader({required this.controller});

  final PartnerController controller;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final responsive = context.responsive;
    final primary = dark ? AppColors.darkText : AppColors.textPrimary;
    final secondary =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BaderIconButton(
          icon: 'assets/icons/bell-ringing-2.png',
          tooltip: 'partner_notifications'.tr,
          onPressed: controller.openNotifications,
        ),
        const SizedBox(width: AppSpacing.sm),
        BaderIconButton(
          icon: 'assets/icons/settings.png',
          tooltip: 'settings'.tr,
          onPressed: controller.openSettings,
        ),
      ],
    );

    final greeting = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'partner_manager_mode'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.small.copyWith(
              color: secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Obx(() {
            final displayName = controller.profile.value?.displayName.trim();
            return Text(
              displayName?.isNotEmpty == true
                  ? (displayName ?? 'partner'.tr)
                  : 'partner'.tr,
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
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360 || responsive.veryLargeText) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [greeting]),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: actions,
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            greeting,
            const SizedBox(width: AppSpacing.lg),
            actions,
          ],
        );
      },
    );
  }
}
