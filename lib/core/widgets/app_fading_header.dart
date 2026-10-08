import 'package:flutter/material.dart';

/// Reuses the scroll/fade timing approved on Initiatives without attaching
/// listeners to whole pages. Only the small header subtree is rebuilt as the
/// sliver's local scroll offset changes.
class AppFadingHeaderSliver extends StatelessWidget {
  const AppFadingHeaderSliver({
    super.key,
    required this.child,
    this.fadeDistance = 120,
  });

  final Widget child;
  final double fadeDistance;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final distance = fadeDistance <= 0 ? 1.0 : fadeDistance;
        final progress =
            (constraints.scrollOffset / distance).clamp(0.0, 1.0);

        return SliverToBoxAdapter(
          child: AppHeaderFade(
            progress: progress,
            child: child,
          ),
        );
      },
    );
  }
}

/// Header-only fade mapping extracted from the approved Initiatives header.
///
/// The title phase starts after 28% of the collapse and completes across the
/// next 58%, with the same subtle upward travel used there.
class AppHeaderFade extends StatelessWidget {
  const AppHeaderFade({
    super.key,
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  static double phase(double progress) {
    return ((progress.clamp(0.0, 1.0) - 0.28) / 0.58).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final fadeProgress = phase(progress);
    final opacity = 1.0 - fadeProgress;

    if (fadeProgress <= 0.001) {
      return child;
    }

    return IgnorePointer(
      ignoring: opacity <= 0.05,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, -fadeProgress * 5),
          child: child,
        ),
      ),
    );
  }
}
