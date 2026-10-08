import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bader_adaptive_tap_surface.dart';
import '../../../../core/widgets/bader_asset_icon.dart';

/// Settings tile kept visually aligned with Card_final1/Bader family settings.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.color,
    this.showChevron = true,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final Color? color;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final interactive = onTap != null;
    final titleColor = color ?? (dark ? AppColors.darkText : AppColors.textPrimary);
    final secondaryColor = dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final iconColor = color ?? AppColors.primary;
    final direction = Directionality.of(context);

    final content = Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: dark ? .16 : .10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: BaderAssetIcon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.small.copyWith(
                    color: interactive ? titleColor : titleColor.withValues(alpha: .78),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(color: secondaryColor),
                  ),
                ],
              ],
            ),
          ),
          if (value != null && value!.trim().isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                value!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTextStyles.label.copyWith(
                  color: color ?? AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          if (showChevron && interactive) ...[
            const SizedBox(width: AppSpacing.sm),
            BaderAssetIcon(
              direction == TextDirection.rtl
                  ? 'assets/icons/chevron-left.png'
                  : 'assets/icons/chevron-right.png',
              size: 18,
              color: secondaryColor,
            ),
          ],
        ],
      ),
    );

    return BaderAdaptiveTapSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: content,
    );
  }
}
