import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import 'bader_shimmer.dart';

class BaderSkeletonBox extends StatelessWidget {
  const BaderSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadius.sm,
    this.opacity = 1.0,
  });

  final double? width;
  final double height;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final inherited = BaderSkeletonPalette.maybeOf(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = inherited?.baseColor ?? BaderSkeletonColors.base(dark: dark);
    final color = base.withValues(alpha: opacity.clamp(0.0, 1.0).toDouble());

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class BaderSkeletonPanel extends StatelessWidget {
  const BaderSkeletonPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = AppRadius.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final inherited = BaderSkeletonPalette.maybeOf(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = inherited?.baseColor ?? BaderSkeletonColors.base(dark: dark);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: base.withValues(alpha: dark ? 0.18 : 0.16),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: base.withValues(alpha: dark ? 0.62 : 0.72),
          width: 0.85,
        ),
      ),
      child: child,
    );
  }
}

class BaderSkeletonTextLine extends StatelessWidget {
  const BaderSkeletonTextLine({
    super.key,
    this.width,
    this.height = 12,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => BaderSkeletonBox(
        width: width,
        height: height,
        radius: AppRadius.xs,
      );
}
