import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_tap_surface.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/loading/bader_shimmer.dart';
import '../../../../core/widgets/loading/bader_skeleton_box.dart';
import '../../../models/scanner_partner_models.dart';

class HomeDashboardLoading extends StatelessWidget {
  const HomeDashboardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaderShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BaderSkeletonBox(height: 104),
          SizedBox(height: AppSpacing.md),
          BaderSkeletonBox(height: 150),
          SizedBox(height: AppSpacing.md),
          BaderSkeletonBox(height: 112),
          SizedBox(height: AppSpacing.md),
          BaderSkeletonBox(height: 60),
          SizedBox(height: AppSpacing.xl),
          BaderSkeletonBox(height: 210),
          SizedBox(height: AppSpacing.xl),
          BaderSkeletonBox(height: 160),
        ],
      ),
    );
  }
}

class HomeContextSummary extends StatelessWidget {
  const HomeContextSummary({
    super.key,
    required this.contextData,
  });

  final ScannerContextData contextData;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final active = contextData.partner.status.trim().toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: dark
              ? const [AppColors.primaryDeep, Color(0xFF0D252C)]
              : const [AppColors.primary, AppColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -18,
            bottom: -24,
            child: IgnorePointer(
              child: BaderAssetIcon(
                'assets/icons/qrcode.png',
                size: 132,
                color: Colors.white.withValues(alpha: .075),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Image.asset(
                      'assets/images/bader_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'scanner_operator_mode'.tr,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: .74),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          contextData.partner.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active ? AppColors.successSoft : AppColors.warningSoft,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _businessStatus(contextData.partner.status),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'scanner_home_hero_hint'.tr,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.small.copyWith(
                  color: Colors.white.withValues(alpha: .82),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeWorkContext extends StatelessWidget {
  const HomeWorkContext({
    super.key,
    required this.contextData,
    required this.isSwitching,
    required this.onSwitchBranch,
  });

  final ScannerContextData contextData;
  final bool isSwitching;
  final VoidCallback onSwitchBranch;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final branch = contextData.branch;
    final device = contextData.scannerDevice;
    final branchName = branch == null ? 'no_selected_branch'.tr : _branchName(context, branch);
    final trustLabel = _trustStatus(device?.trustLevel);
    final secondary = dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BaderFormSurface(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'scanner_context'.tr,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              BaderAdaptiveTapSurface(
                onTap: isSwitching ? null : onSwitchBranch,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    branch == null ? 'select_branch'.tr : 'switch_branch'.tr,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconTile(
                asset: 'assets/icons/map-pin.png',
                background: dark ? AppColors.primarySoftDark : AppColors.primarySoft,
                color: AppColors.primary,
                size: 42,
                iconSize: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'current_branch'.tr,
                      style: AppTextStyles.caption.copyWith(color: secondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      branchName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              _IconTile(
                asset: 'assets/icons/shield-lock.png',
                background: device == null
                    ? (dark ? AppColors.secondarySoftDark : AppColors.secondarySoft)
                    : (dark ? AppColors.primarySoftDark : AppColors.primarySoft),
                color: device == null ? AppColors.secondary : AppColors.primary,
                size: 42,
                iconSize: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'scanner_device'.tr,
                      style: AppTextStyles.caption.copyWith(color: secondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      device == null
                          ? 'scanner_device_unavailable'.tr
                          : 'scanner_device_available'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold,
                    ),
                  ],
                ),
              ),
              if (device != null && trustLabel != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _StatusPill(label: trustLabel, positive: true),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class HomeCurrentBranch extends StatelessWidget {
  const HomeCurrentBranch({
    super.key,
    required this.branch,
    required this.isSwitching,
    required this.onSwitch,
  });

  final PartnerBranchData? branch;
  final bool isSwitching;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final branchName = branch == null ? null : _branchName(context, branch!);
    final location = branch?.location?.address?.trim();

    return BaderFormSurface(
      backgroundColor:
          dark ? AppColors.primarySoftDark : AppColors.primarySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconTile(
                asset: 'assets/icons/map-pin.png',
                background:
                    dark ? AppColors.darkSurface2 : AppColors.surface,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'current_branch'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: dark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      branchName ?? 'no_selected_branch'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: dark ? AppColors.darkText : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (branch != null && location != null && location.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small.copyWith(
                          color: dark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (branch == null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'no_selected_branch_message'.tr,
              style: AppTextStyles.small.copyWith(
                color: dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: branch == null ? 'select_branch'.tr : 'switch_branch'.tr,
            onPressed: isSwitching ? null : onSwitch,
            isLoading: isSwitching,
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class HomeScannerDevice extends StatelessWidget {
  const HomeScannerDevice({
    super.key,
    required this.device,
  });

  final ScannerDeviceData? device;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final available = device != null;
    final trustLabel = _trustStatus(device?.trustLevel);

    return BaderFormSurface(
      child: Row(
        children: [
          _IconTile(
            asset: 'assets/icons/shield-lock.png',
            background: available
                ? (dark ? AppColors.primarySoftDark : AppColors.primarySoft)
                : (dark ? AppColors.secondarySoftDark : AppColors.secondarySoft),
            color: available ? AppColors.primary : AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'scanner_device'.tr,
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  available
                      ? 'scanner_device_available'.tr
                      : 'scanner_device_unavailable'.tr,
                  style: AppTextStyles.small.copyWith(
                    color: dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (available && trustLabel != null)
            _StatusPill(
              label: trustLabel,
              positive: true,
            ),
        ],
      ),
    );
  }
}

class HomePrimaryScanCta extends StatelessWidget {
  const HomePrimaryScanCta({
    super.key,
    required this.enabled,
    required this.onScan,
  });

  final bool enabled;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BaderFormSurface(
      elevated: true,
      backgroundColor: dark ? AppColors.secondarySoftDark : AppColors.secondarySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: dark ? .22 : .12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const BaderAssetIcon(
                  'assets/icons/qrcode.png',
                  size: 27,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'scan_qr'.tr,
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'scanner_home_hero_hint'.tr,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small.copyWith(
                        color: secondaryText,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'scan_qr'.tr,
            icon: 'assets/icons/scan.png',
            onPressed: enabled ? onScan : null,
            height: 56,
            radius: AppRadius.lg,
            backgroundColor: AppColors.secondary,
          ),
          if (!enabled) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'scan_requires_branch_device'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: secondaryText),
            ),
          ],
        ],
      ),
    );
  }
}

class HomeDailyStatistics extends StatelessWidget {
  const HomeDailyStatistics({
    super.key,
    required this.statistics,
  });

  final PartnerDailyStatisticsData statistics;

  @override
  Widget build(BuildContext context) {
    final metrics = <_StatisticValue>[
      _StatisticValue(
        label: 'successful_redemptions'.tr,
        value: statistics.successfulRedemptions.toString(),
        asset: 'assets/icons/check.png',
        accent: AppColors.primary,
      ),
      _StatisticValue(
        label: 'failed_redemptions'.tr,
        value: statistics.failedRedemptions.toString(),
        asset: 'assets/icons/shield-lock.png',
        accent: AppColors.secondary,
      ),
      _StatisticValue(
        label: 'total_discount_amount'.tr,
        value: _number(statistics.totalDiscountAmount),
        asset: 'assets/icons/tags.png',
        accent: AppColors.primary,
      ),
      _StatisticValue(
        label: 'points_spent'.tr,
        value: statistics.pointsSpent.toString(),
        asset: 'assets/icons/credits.png',
        accent: AppColors.secondary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: 'today_statistics'.tr),
        const SizedBox(height: AppSpacing.md),
        _SimpleStatisticsSurface(metrics: metrics),
      ],
    );
  }
}

class _SimpleStatisticsSurface extends StatelessWidget {
  const _SimpleStatisticsSurface({
    required this.metrics,
  });

  final List<_StatisticValue> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SimpleStatisticMetric(
                item: metrics[0],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SimpleStatisticMetric(
                item: metrics[1],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        _StatisticWideMetric(
          item: metrics[2],
        ),

        const SizedBox(height: AppSpacing.md),

        _StatisticWideMetric(
          item: metrics[3],
        ),
      ],
    );
  }
}

class _StatisticWideMetric extends StatelessWidget {
  const _StatisticWideMetric({
    required this.item,
  });

  final _StatisticValue item;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final primaryText =
    dark ? AppColors.darkText : AppColors.textPrimary;

    final secondaryText =
    dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final border =
    dark ? AppColors.darkBorder : AppColors.border;

    final surface =
    dark ? AppColors.darkSurface : AppColors.surface;

    final iconBackground = item.accent == AppColors.secondary
        ? (
        dark
            ? AppColors.secondarySoftDark
            : AppColors.secondarySoft
    )
        : (
        dark
            ? AppColors.primarySoftDark
            : AppColors.primarySoft
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: BaderAssetIcon(
              item.asset,
              size: 18,
              color: item.accent,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyBold.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleStatisticMetric extends StatelessWidget {
  const _SimpleStatisticMetric({
    required this.item,
  });

  final _StatisticValue item;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final primaryText =
    dark ? AppColors.darkText : AppColors.textPrimary;

    final secondaryText =
    dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final border =
    dark ? AppColors.darkBorder : AppColors.border;

    final surface =
    dark ? AppColors.darkSurface : AppColors.surface;

    final iconBackground = item.accent == AppColors.secondary
        ? (
        dark
            ? AppColors.secondarySoftDark
            : AppColors.secondarySoft
    )
        : (
        dark
            ? AppColors.primarySoftDark
            : AppColors.primarySoft
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: BaderAssetIcon(
              item.asset,
              size: 16,
              color: item.accent,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyBold.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: secondaryText,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
class HomeRecentRedemptions extends StatelessWidget {
  const HomeRecentRedemptions({
    super.key,
    required this.redemptions,
    required this.onSeeAll,
  });

  final List<RedemptionReceipt> redemptions;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'recent_redemptions'.tr,
          actionLabel: redemptions.isEmpty ? null : 'view_all'.tr,
          onAction: redemptions.isEmpty ? null : onSeeAll,
        ),
        const SizedBox(height: AppSpacing.md),
        if (redemptions.isEmpty)
          BaderFormSurface(
            child: Row(
              children: [
                _IconTile(
                  asset: 'assets/icons/file-invoice.png',
                  background: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.primarySoftDark
                      : AppColors.primarySoft,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'no_redemptions_today'.tr,
                        style: AppTextStyles.bodyBold,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'no_redemptions_today_message'.tr,
                        style: AppTextStyles.small.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < redemptions.length; i++) ...[
                _RedemptionPreview(receipt: redemptions[i]),
                if (i != redemptions.length - 1)
                  const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
      ],
    );
  }
}

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.onRedemptions,
    required this.onStatistics,
    required this.onSettings,
  });

  final VoidCallback onRedemptions;
  final VoidCallback onStatistics;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionData>[
      _QuickActionData(
        label: 'redemption_history'.tr,
        asset: 'assets/icons/file-invoice.png',
        onTap: onRedemptions,
      ),
      _QuickActionData(
        label: 'daily_statistics'.tr,
        asset: 'assets/icons/stack-2.png',
        onTap: onStatistics,
      ),
      _QuickActionData(
        label: 'settings'.tr,
        asset: 'assets/icons/settings.png',
        onTap: onSettings,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: 'quick_actions'.tr),
        const SizedBox(height: AppSpacing.md),
        _QuickAccessSurface(actions: actions),
      ],
    );
  }
}

class _QuickAccessSurface extends StatelessWidget {
  const _QuickAccessSurface({required this.actions});

  final List<_QuickActionData> actions;

  static const _palette = <Color>[
    AppColors.primaryDeep,
    AppColors.primary,
    AppColors.secondary,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = context.responsive;
        final gap = responsive.isNarrow ? AppSpacing.sm : AppSpacing.md;
        final visibleItems = responsive.largeText
            ? 2.25
            : constraints.maxWidth >= 620
                ? 4.15
                : constraints.maxWidth >= 400
                    ? 3.15
                    : 2.55;
        final fittedThreeItemWidth =
            (constraints.maxWidth - gap * (actions.length - 1)) / actions.length;
        final itemWidth = actions.length <= 3 && !responsive.largeText
            ? fittedThreeItemWidth.clamp(88.0, 132.0).toDouble()
            : ((constraints.maxWidth - gap * (visibleItems - 1)) / visibleItems)
                .clamp(108.0, 176.0)
                .toDouble();
        final itemHeight =
            responsive.largeText ? itemWidth * 1.38 : itemWidth * 1.3;

        final totalWidth =
            (actions.length * itemWidth) + ((actions.length - 1) * gap);

        if (totalWidth <= constraints.maxWidth) {
          return SizedBox(
            height: itemHeight,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < actions.length; index++) ...[
                    SizedBox(
                      width: itemWidth,
                      child: _HomeQuickActionTile(
                        action: actions[index],
                        tint: _palette[index % _palette.length],
                      ),
                    ),
                    if (index != actions.length - 1) SizedBox(width: gap),
                  ],
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: itemHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: actions.length,
            separatorBuilder: (_, __) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              return SizedBox(
                width: itemWidth,
                child: _HomeQuickActionTile(
                  action: actions[index],
                  tint: _palette[index % _palette.length],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _HomeQuickActionTile extends StatefulWidget {
  const _HomeQuickActionTile({
    required this.action,
    required this.tint,
  });

  final _QuickActionData action;
  final Color tint;

  @override
  State<_HomeQuickActionTile> createState() => _HomeQuickActionTileState();
}

class _HomeQuickActionTileState extends State<_HomeQuickActionTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final radius = BorderRadius.circular(AppRadius.xxl);

    return Semantics(
      button: true,
      label: widget.action.label,
      child: Listener(
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? .96 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: BaderAdaptiveTapSurface(
            onTap: widget.action.onTap,
            borderRadius: radius,
            child: Container(
              decoration: BoxDecoration(
                color: widget.tint,
                borderRadius: radius,
                boxShadow: _pressed ? const [] : AppShadows.card,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PositionedDirectional(
                    end: -14,
                    bottom: -14,
                    child: Opacity(
                      opacity: .14,
                      child: BaderAssetIcon(
                        widget.action.asset,
                        size: responsive.largeText ? 72 : 82,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(
                      responsive.isNarrow ? AppSpacing.md : AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BaderAssetIcon(
                          widget.action.asset,
                          size: responsive.largeText ? 32 : 38,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          widget.action.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyBold.copyWith(
                            color: Colors.white,
                            fontSize: responsive.largeText ? 13 : 15,
                            fontWeight: FontWeight.w900,
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeBranchPickerContent extends StatelessWidget {
  const HomeBranchPickerContent({
    super.key,
    required this.branches,
    required this.selectedBranchPublicId,
  });

  final List<PartnerBranchData> branches;
  final String? selectedBranchPublicId;

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          'no_scanner_branches_available'.tr,
          style: AppTextStyles.body,
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: branches.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (itemContext, index) {
          final branch = branches[index];
          final selected = branch.publicId == selectedBranchPublicId;
          return BaderFormSurface(
            padding: EdgeInsets.zero,
            backgroundColor: selected
                ? (Theme.of(itemContext).brightness == Brightness.dark
                    ? AppColors.primarySoftDark
                    : AppColors.primarySoft)
                : null,
            child: BaderAdaptiveTapSurface(
              onTap: () => Navigator.of(itemContext).pop(branch),
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _branchName(itemContext, branch),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold,
                          ),
                          if (branch.location?.address?.trim().isNotEmpty ?? false) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              branch.location!.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: Theme.of(itemContext).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: AppSpacing.md),
                      const BaderAssetIcon(
                        'assets/icons/check.png',
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RedemptionPreview extends StatelessWidget {
  const _RedemptionPreview({required this.receipt});

  final RedemptionReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final detail = _redemptionDetail(receipt);
    return BaderFormSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _IconTile(
            asset: 'assets/icons/file-invoice.png',
            background: Theme.of(context).brightness == Brightness.dark
                ? AppColors.primarySoftDark
                : AppColors.primarySoft,
            color: AppColors.primary,
            size: 42,
            iconSize: 19,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('redemption'.tr, style: AppTextStyles.bodyBold),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _dateTime(receipt.occurredAt),
            style: AppTextStyles.micro.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkMuted
                  : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  String _redemptionDetail(RedemptionReceipt value) {
    if (value.discountAmount != null) {
      final currency = value.currencyCode?.trim();
      return 'redemption_discount_value'.trParams({
        'value': _number(value.discountAmount!),
        'currency': currency == null || currency.isEmpty ? '' : currency,
      }).trim();
    }
    if (value.pointsCostSnapshot != null) {
      return 'redemption_points_value'.trParams({
        'value': value.pointsCostSnapshot.toString(),
      });
    }
    if (value.invoiceAmount != null) {
      final currency = value.currencyCode?.trim();
      return 'redemption_invoice_value'.trParams({
        'value': _number(value.invoiceAmount!),
        'currency': currency == null || currency.isEmpty ? '' : currency,
      }).trim();
    }
    return 'redemption_completed'.tr;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          BaderAdaptiveTapSurface(
            onTap: onAction,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                actionLabel!,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.positive,
  });

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = positive
        ? (dark ? AppColors.primarySoftDark : AppColors.successSoft)
        : (dark ? AppColors.darkSurface2 : AppColors.surfaceElevated);
    final foreground = positive
        ? (dark ? AppColors.darkText : AppColors.success)
        : (dark ? AppColors.darkTextSecondary : AppColors.textSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.asset,
    required this.background,
    required this.color,
    this.size = 48,
    this.iconSize = 22,
  });

  final String asset;
  final Color background;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      alignment: Alignment.center,
      child: BaderAssetIcon(asset, size: iconSize, color: color),
    );
  }
}

class _StatisticValue {
  const _StatisticValue({
    required this.label,
    required this.value,
    required this.asset,
    required this.accent,
  });

  final String label;
  final String value;
  final String asset;
  final Color accent;
}

class _QuickActionData {
  const _QuickActionData({
    required this.label,
    required this.asset,
    required this.onTap,
  });
  final String label;
  final String asset;
  final VoidCallback onTap;
}

String _branchName(BuildContext context, PartnerBranchData branch) {
  final languageCode = Localizations.localeOf(context).languageCode;
  if (languageCode == 'ar') return branch.nameAr;
  final translated = branch.nameEn?.trim();
  return translated == null || translated.isEmpty ? branch.nameAr : translated;
}

String _businessStatus(String status) {
  switch (status.trim().toLowerCase()) {
    case 'active':
      return 'status_active'.tr;
    case 'pending':
      return 'status_pending'.tr;
    case 'draft':
      return 'status_draft'.tr;
    case 'disabled':
      return 'status_disabled'.tr;
    case 'inactive':
      return 'status_inactive'.tr;
    case 'suspended':
      return 'status_suspended'.tr;
    default:
      final normalized = status.trim().replaceAll('_', ' ');
      if (normalized.isEmpty) return '—';
      return normalized[0].toUpperCase() + normalized.substring(1);
  }
}

String? _trustStatus(String? trustLevel) {
  switch (trustLevel?.trim().toLowerCase()) {
    case 'trusted':
      return 'trust_trusted'.tr;
    default:
      return null;
  }
}

String _number(Object value) {
  if (value is String) return value.replaceFirst(RegExp(r'\.00$'), '');
  final number = value as num;
  if (number is int || number == number.round()) return number.toInt().toString();
  return number.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');
}

String _dateTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}
