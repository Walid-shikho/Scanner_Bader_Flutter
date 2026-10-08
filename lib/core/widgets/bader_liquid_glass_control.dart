import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Shared interaction chrome for Bader navigation/action controls.
///
/// iOS 26+ delegates the surface and interaction to adaptive_platform_ui's
/// native UIButton/Liquid Glass implementation. Android and legacy iOS keep a
/// lightweight Bader/Material fallback; no manual blur is introduced here.
class BaderLiquidGlassControl extends StatelessWidget {
  const BaderLiquidGlassControl({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 44,
    this.enabled = true,
    this.prominent = false,
    this.tintColor,
    this.fallbackBackgroundColor,
    this.fallbackBorderRadius,
    this.tooltip,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final bool enabled;
  final bool prominent;
  final Color? tintColor;
  final Color? fallbackBackgroundColor;
  final BorderRadius? fallbackBorderRadius;
  final String? tooltip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final nativeGlass = PlatformInfo.isIOS26OrHigher();

    Widget control;
    if (nativeGlass) {
      control = SizedBox.square(
        dimension: size,
        child: AdaptiveButton.child(
          onPressed: active ? onPressed : null,
          enabled: active,
          style: prominent
              ? AdaptiveButtonStyle.prominentGlass
              : AdaptiveButtonStyle.glass,
          color: tintColor,
          minSize: Size.square(size),
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          useSmoothRectangleBorder: false,
          child: IgnorePointer(child: child),
        ),
      );
    } else {
      final background = fallbackBackgroundColor ??
          (dark ? AppColors.darkSurfaceElevated : AppColors.surface);

      final radius = fallbackBorderRadius;
      control = SizedBox.square(
        dimension: size,
        child: Material(
          color: background,
          shape: radius == null
              ? const CircleBorder()
              : RoundedRectangleBorder(borderRadius: radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: active ? onPressed : null,
            customBorder: radius == null ? const CircleBorder() : null,
            borderRadius: radius,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: active ? 1 : .5,
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    control = Semantics(
      button: true,
      enabled: active,
      label: semanticLabel,
      child: control,
    );

    final message = tooltip?.trim();
    if (message != null && message.isNotEmpty) {
      control = Tooltip(message: message, child: control);
    }

    return control;
  }
}

/// Shared capsule variant for text/group actions in page chrome.
class BaderLiquidGlassButton extends StatelessWidget {
  const BaderLiquidGlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.enabled = true,
    this.prominent = false,
    this.tintColor,
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.fallbackBackgroundColor,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool prominent;
  final Color? tintColor;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? fallbackBackgroundColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final nativeGlass = PlatformInfo.isIOS26OrHigher();

    Widget control;
    if (nativeGlass) {
      control = ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: AdaptiveButton.child(
          onPressed: active ? onPressed : null,
          enabled: active,
          style: prominent
              ? AdaptiveButtonStyle.prominentGlass
              : AdaptiveButtonStyle.glass,
          color: tintColor,
          minSize: Size(0, height),
          padding: padding,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          useSmoothRectangleBorder: false,
          child: IgnorePointer(child: child),
        ),
      );
    } else {
      final background = fallbackBackgroundColor ??
          (dark ? AppColors.darkSurfaceElevated : AppColors.surface);
      control = Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: active ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: padding,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: active ? 1 : .5,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: active,
      label: semanticLabel,
      child: control,
    );
  }
}
