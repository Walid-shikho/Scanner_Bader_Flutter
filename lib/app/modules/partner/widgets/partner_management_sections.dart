import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bader_adaptive_tap_surface.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../models/scanner_partner_models.dart';



class PartnerHomeMosaicTile extends StatelessWidget {
  const PartnerHomeMosaicTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.onTap,
    this.showSubtitle = true,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color background;
  final VoidCallback onTap;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBackground = dark
        ? Color.lerp(AppColors.darkSurface, background, .58)!
        : background;
    final radius = BorderRadius.circular(AppRadius.xl);

    return Semantics(
      button: true,
      label: title,
      child: BaderAdaptiveTapSurface(
        onTap: onTap,
        borderRadius: radius,
        splashColor: Colors.white.withValues(alpha: .10),
        highlightColor: Colors.white.withValues(alpha: .06),
        child: ClipRRect(
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: effectiveBackground,
              borderRadius: radius,
              boxShadow: dark ? const [] : AppShadows.subtle,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PositionedDirectional(
                  end: -12,
                  bottom: -18,
                  child: IgnorePointer(
                    child: BaderAssetIcon(
                      icon,
                      size: 104,
                      color: Colors.white,
                      opacity: .16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BaderAssetIcon(
                          icon,
                          size: 21,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyBold.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        if (showSubtitle) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: .82),
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PartnerManagementActionTile extends StatelessWidget {
  const PartnerManagementActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accent = AppColors.primary,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final String icon;
  final VoidCallback onTap;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? AppColors.darkText : AppColors.textPrimary;
    final secondary = dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final direction = Directionality.of(context);

    return Semantics(
      button: true,
      label: title,
      child: BaderAdaptiveTapSurface(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: border),
            boxShadow: dark ? const [] : AppShadows.subtle,
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ActionIcon(icon: icon, accent: accent),
                        const Spacer(),
                        BaderAssetIcon(
                          direction == TextDirection.rtl
                              ? 'assets/icons/chevron-left.png'
                              : 'assets/icons/chevron-right.png',
                          size: 17,
                          color: secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(color: secondary),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _ActionIcon(icon: icon, accent: accent),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.body.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w600,
                              fontSize: 18
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.small.copyWith(color: secondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    BaderAssetIcon(
                      direction == TextDirection.rtl
                          ? 'assets/icons/chevron-left.png'
                          : 'assets/icons/chevron-right.png',
                      size: 18,
                      color: secondary,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.accent});

  final String icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return BaderAssetIcon(icon, color: accent, size: 24);
  }
}

class PartnerStatusChip extends StatelessWidget {
  const PartnerStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final normalized = status.trim().toLowerCase();
    final positive = normalized == 'active' || normalized == 'trusted' || normalized == 'verified';
    final warning = normalized == 'pending' || normalized == 'draft';
    final danger = normalized == 'disabled' || normalized == 'suspended' || normalized == 'inactive';
    final color = positive
        ? AppColors.success
        : warning
            ? AppColors.warning
            : danger
                ? AppColors.danger
                : AppColors.primary;
    final background = color.withValues(alpha: dark ? .17 : .09);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        _statusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class PartnerInfoRow extends StatelessWidget {
  const PartnerInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class PartnerBranchCard extends StatelessWidget {
  const PartnerBranchCard({
    super.key,
    required this.branch,
    required this.onEdit,
  });

  final PartnerBranchData branch;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final name = language == 'ar'
        ? branch.nameAr
        : (branch.nameEn?.trim().isNotEmpty ?? false)
            ? branch.nameEn!
            : branch.nameAr;
    final address = branch.location?.address?.trim();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BaderAdaptiveTapSurface(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BaderFormSurface(
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ActionIcon(
                  icon: 'assets/icons/map-pin.png',
                  accent: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (address != null && address.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(color: secondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                PartnerStatusChip(status: branch.status),
              ],
            ),
            if (branch.phone != null && branch.phone!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              PartnerInfoRow(label: 'branch_phone'.tr, value: branch.phone!),
            ],
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                'edit_branch'.tr,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerDeviceCard extends StatelessWidget {
  const ScannerDeviceCard({super.key, required this.device});

  final ScannerDeviceData device;

  @override
  Widget build(BuildContext context) {
    return BaderFormSurface(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _ActionIcon(
                icon: 'assets/icons/shield-lock.png',
                accent: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'scanner_device'.tr,
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              PartnerStatusChip(status: device.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PartnerInfoRow(
            label: 'device_trust'.tr,
            value: _trustLabel(device.trustLevel),
          ),
          PartnerInfoRow(
            label: 'device_status'.tr,
            value: _statusLabel(device.status),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'active' => 'status_active'.tr,
    'pending' => 'status_pending'.tr,
    'disabled' => 'status_disabled'.tr,
    'inactive' => 'status_inactive'.tr,
    'suspended' => 'status_suspended'.tr,
    'draft' => 'status_draft'.tr,
    _ => _humanizeCode(raw),
  };
}

String _trustLabel(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'trusted' => 'trust_trusted'.tr,
    'untrusted' => 'trust_untrusted'.tr,
    'pending' => 'status_pending'.tr,
    _ => _humanizeCode(raw),
  };
}

String _humanizeCode(String raw) {
  final normalized = raw.trim().replaceAll(RegExp(r'[_-]+'), ' ');
  if (normalized.isEmpty) return '—';
  return normalized
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
