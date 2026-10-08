import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

/// A lightweight adaptive tap target for custom Bader surfaces.
///
/// Android keeps Material ink feedback. iOS uses a gesture-only surface so
/// custom cards do not show an Android ripple while preserving the same
/// layout, callbacks, and hit testing.
class BaderAdaptiveTapSurface extends StatelessWidget {
  const BaderAdaptiveTapSurface({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.customBorder,
    this.splashColor,
    this.highlightColor,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final Color? splashColor;
  final Color? highlightColor;
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return GestureDetector(
        behavior: behavior,
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      );
    }

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: borderRadius,
      customBorder: customBorder,
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}
