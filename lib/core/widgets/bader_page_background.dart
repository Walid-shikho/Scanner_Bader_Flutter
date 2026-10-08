import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../responsive/app_responsive.dart';
import '../theme/bader_page_background_theme.dart';

/// Shared BADER page atmosphere: soft brand accent at the top, then the
/// normal scaffold surface. The decoration is painted once per page and stays
/// behind scrolling content, so it is intentionally cheap to render.
///
/// System UI overlay ownership intentionally lives in [BaderAdaptiveScaffold]
/// so there is only one status-bar style source for a page.
class BaderPageBackground extends StatelessWidget {
  const BaderPageBackground({
    super.key,
    required this.child,
    this.accentScale = 1,
  });

  final Widget child;
  final double accentScale;

  @override
  Widget build(BuildContext context) {
    final palette = BaderPageBackgroundTheme.of(context);
    final responsive = context.responsive;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    final preferredAccentHeight = responsive.responsiveDouble(
          compact: 286,
          medium: 318,
          expanded: 338,
        ) *
        accentScale;

    final viewportCap = viewportHeight *
        (responsive.isTabletLike ? .36 : .43);

    final accentHeight = math
        .min(preferredAccentHeight, viewportCap)
        .clamp(210.0, 380.0)
        .toDouble();

    return ColoredBox(
      color: palette.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            height: accentHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.accentStart,
                      palette.accentMiddle,
                      palette.accentEnd,
                    ],
                    stops: const [0, .52, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
