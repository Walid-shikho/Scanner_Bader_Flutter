import 'package:flutter/material.dart';

import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon ='assets/icons/file-empty.png',
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final responsive = context.responsive;
    final iconBox = responsive.isNarrow ? 68.0 : 80.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.isNarrow ? AppSpacing.xl : AppSpacing.xxxl,
          vertical: responsive.isLandscape ? AppSpacing.xxxl : AppSpacing.huge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: dark ? 0.16 : 0.08),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: dark ? 0.25 : 0.15),
                  width: 1,
                ),
              ),
              child: Image.asset(
                icon,
                width: responsive.isNarrow ? 32 : 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextStyles.sectionTitleSize,
                fontWeight: FontWeight.w800,
                color: dark ? AppColors.darkText : AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTextStyles.smallSize,
                  height: 1.55,
                  color: dark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        responsive.isNarrow ? AppSpacing.xl : AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
