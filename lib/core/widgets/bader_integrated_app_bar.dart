import 'dart:math' as math;

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'bader_liquid_glass_control.dart';
import 'bader_page_safe_area.dart';

/// Edge-to-edge Bader page chrome used on modern iOS instead of a full-width
/// translucent native toolbar surface.
///
/// The page background remains visible behind the status/toolbar region while
/// the interactive controls themselves are still native Liquid Glass buttons
/// through [BaderLiquidGlassControl]/[BaderLiquidGlassButton].
class BaderIntegratedAdaptiveAppBar extends StatelessWidget {
  const BaderIntegratedAdaptiveAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<AdaptiveAppBarAction>? actions;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? AppColors.darkText : AppColors.textPrimary;
    final toolbarHeight = BaderPageSafeArea.toolbarExtentOf(context);
    final horizontal = context.responsive.horizontalPagePadding;
    final actionList = actions ?? const <AdaptiveAppBarAction>[];

    final leadingReserve = leading == null ? 0.0 : 52.0;
    final trailingReserve = actionList.fold<double>(0, (sum, action) {
      final hasText = action.title?.trim().isNotEmpty ?? false;
      return sum + (hasText ? 116.0 : 52.0);
    });
    final sideReserve = math.max(leadingReserve, trailingReserve);

    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: SizedBox(
        height: toolbarHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sideReserve + AppSpacing.sm,
                  ),
                  child: Center(
                    child: _CenteredTitle(
                      title: title,
                      subtitle: subtitle,
                      foreground: foreground,
                    ),
                  ),
                ),
              ),
            ),
            if (leading != null)
              PositionedDirectional(
                start: horizontal,
                top: 0,
                bottom: 0,
                child: Center(child: leading),
              ),
            if (actionList.isNotEmpty)
              PositionedDirectional(
                end: horizontal,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < actionList.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.xs),
                        _IntegratedAction(
                          action: actionList[i],
                          foreground: foreground,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CenteredTitle extends StatelessWidget {
  const _CenteredTitle({
    required this.title,
    required this.subtitle,
    required this.foreground,
  });

  final String? title;
  final String? subtitle;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title?.trim() ?? '';
    final resolvedSubtitle = subtitle?.trim() ?? '';
    if (resolvedTitle.isEmpty && resolvedSubtitle.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (resolvedTitle.isNotEmpty)
          Text(
            resolvedTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyBold.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        if (resolvedSubtitle.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            resolvedSubtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.micro.copyWith(
              color: foreground.withValues(alpha: .72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _IntegratedAction extends StatelessWidget {
  const _IntegratedAction({
    required this.action,
    required this.foreground,
  });

  final AdaptiveAppBarAction action;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final title = action.title?.trim();
    if (title != null && title.isNotEmpty) {
      return BaderLiquidGlassButton(
        onPressed: action.onPressed,
        prominent: action.prominent,
        tintColor: action.tintColor,
        semanticLabel: title,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.small.copyWith(
            color: action.tintColor ?? foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final iconWidget = action.iconWidget;
    final icon = action.icon;
    final child = iconWidget ??
        (icon != null
            ? Icon(
                icon,
                size: 20,
                color: action.tintColor ?? foreground,
              )
            : const SizedBox.shrink());

    return BaderLiquidGlassControl(
      onPressed: action.onPressed,
      prominent: action.prominent,
      tintColor: action.tintColor,
      child: child,
    );
  }
}
