import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Shared Bader shimmer engine.
///
/// One instance should wrap a complete visible skeleton subtree. Skeleton
/// shapes themselves remain static and never own animation controllers.
class BaderShimmer extends StatefulWidget {
  const BaderShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1300),
  });

  final Widget child;
  final Duration duration;

  @override
  State<BaderShimmer> createState() => _BaderShimmerState();
}

class _BaderShimmerState extends State<BaderShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.of(context).disableAnimations;
    if (_reducedMotion == reduced &&
        ((reduced && !_controller.isAnimating) ||
            (!reduced && _controller.isAnimating))) {
      return;
    }
    _reducedMotion = reduced;
    if (reduced) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BaderShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      if (!_reducedMotion) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = BaderSkeletonColors.base(dark: dark);
    final highlight = BaderSkeletonColors.highlight(dark: dark);

    final staticChild = BaderSkeletonPalette(
      baseColor: base,
      highlightColor: highlight,
      child: widget.child,
    );

    if (_reducedMotion) return staticChild;

    final textDirection = Directionality.of(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: staticChild,
        builder: (context, child) {
          final progress = textDirection == TextDirection.rtl
              ? 1.0 - _controller.value
              : _controller.value;
          final center = -2.0 + (progress * 4.0);
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment(center - 1.1, 0),
              end: Alignment(center + 1.1, 0),
              colors: [base, highlight, base],
              stops: const [0.20, 0.50, 0.80],
            ).createShader(bounds),
            child: child,
          );
        },
      ),
    );
  }
}

abstract final class BaderSkeletonColors {
  static Color base({required bool dark}) => dark
      ? Color.lerp(AppColors.darkSurface2, AppColors.darkBorder, 0.30)!
      : Color.lerp(AppColors.surfaceElevated, AppColors.border, 0.24)!;

  static Color highlight({required bool dark}) => dark
      ? Color.lerp(AppColors.darkSurfaceElevated, AppColors.darkText, 0.045)!
      : Color.lerp(AppColors.surfaceHighlight, AppColors.surface, 0.45)!;
}

class BaderSkeletonPalette extends InheritedWidget {
  const BaderSkeletonPalette({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required super.child,
  });

  final Color baseColor;
  final Color highlightColor;

  static BaderSkeletonPalette? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BaderSkeletonPalette>();

  @override
  bool updateShouldNotify(BaderSkeletonPalette oldWidget) =>
      baseColor != oldWidget.baseColor || highlightColor != oldWidget.highlightColor;
}
