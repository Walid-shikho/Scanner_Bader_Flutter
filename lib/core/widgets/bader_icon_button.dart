import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'bader_liquid_glass_control.dart';

class BaderIconButton extends StatelessWidget {
  const BaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.badge = false,
    this.size = 44,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  final String icon;
  final VoidCallback onPressed;
  final bool badge;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final resolvedIcon =
        iconColor ?? (dark ? AppColors.darkText : AppColors.textPrimary);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        BaderLiquidGlassControl(
          size: size,
          onPressed: onPressed,
          tooltip: tooltip,
          fallbackBackgroundColor: backgroundColor,
          fallbackBorderRadius: BorderRadius.circular(AppRadius.lg),
          child: Image.asset(
            icon,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            color: resolvedIcon,
          ),
        ),
        if (badge)
          PositionedDirectional(
            top: -1,
            end: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: dark ? AppColors.darkSurfaceElevated : Colors.white,
                  width: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
