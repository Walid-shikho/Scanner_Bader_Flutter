import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.height = 52,
    this.radius = AppRadius.lg,
    this.isLoading = false,
    this.hasGlow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final double radius;
  final bool isLoading;
  final bool hasGlow;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final info = context.responsive;
    final effectiveHeight = info.veryLargeText
        ? height + 14
        : info.largeText
            ? height + 6
            : height;

    return SizedBox(
      width: double.infinity,
      height: effectiveHeight,
      child: AdaptiveButton.child(
        onPressed: enabled ? onPressed : null,
        enabled: enabled,
        color: backgroundColor,
        style: PlatformInfo.isIOS26OrHigher()
            ? AdaptiveButtonStyle.prominentGlass
            : AdaptiveButtonStyle.filled,
        borderRadius: BorderRadius.circular(radius),
        minSize: Size(0, effectiveHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        child: isLoading
            ? SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2.1,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      foregroundColor
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Image.asset(icon!, width: 20, color: foregroundColor),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: info.veryLargeText ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.button.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
