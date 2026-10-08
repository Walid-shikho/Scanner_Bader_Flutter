import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bader_asset_icon.dart';

class ThemeOptionButton extends StatelessWidget {
  const ThemeOptionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final responsive = context.responsive;

    final backgroundColor = selected
        ? (dark ? AppColors.primarySoftDark : AppColors.primarySoft)
        : (dark ? AppColors.darkSurface2 : AppColors.surfaceElevated);
    final borderColor = selected
        ? AppColors.primary
        : (dark ? AppColors.darkBorder : AppColors.border);
    final textColor = selected
        ? AppColors.primary
        : (dark ? AppColors.darkText : AppColors.textPrimary);
    final secondaryColor =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final height = responsive.veryLargeText
        ? 96.0
        : responsive.largeText
            ? 88.0
            : 80.0;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: AdaptiveButton.child(
        onPressed: onTap,
        enabled: true,
        color: backgroundColor,
        style: PlatformInfo.isIOS26OrHigher()
            ? selected
                ? AdaptiveButtonStyle.prominentGlass
                : AdaptiveButtonStyle.glass
            : AdaptiveButtonStyle.filled,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        minSize: Size(0, height),
        padding: EdgeInsets.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppColors.primary
                      : (dark ? AppColors.darkSurface : AppColors.surface),
                  border: Border.all(
                    color: selected ? AppColors.primary : borderColor,
                  ),
                ),
                child: BaderAssetIcon(
                  icon,
                  size: 19,
                  color: selected ? Colors.white : secondaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: responsive.veryLargeText ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.small.copyWith(
                    color: textColor,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 18 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
