import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'bader_asset_icon.dart';

/// Canonical Bader-family section heading used by sibling applications.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.actionLabel,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sectionTitle.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkText
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (onSeeAll != null) ...[
            const SizedBox(width: AppSpacing.md),
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel ?? 'view_all'.tr,
                      maxLines: 1,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    BaderAssetIcon(
                      Directionality.of(context) == TextDirection.rtl
                          ? 'assets/icons/chevron-left.png'
                          : 'assets/icons/chevron-right.png',
                      size: 11,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
