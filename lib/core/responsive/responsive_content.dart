import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

/// Centers app content, caps it on wide windows and applies window-class aware
/// horizontal gutters. It uses the local constraints instead of the global
/// screen width so it also behaves correctly in split screen / nested panes.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 760,
    this.compactPadding = 18,
    this.narrowPadding = 14,
    this.mediumPadding = 28,
    this.expandedPadding = 36,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final double compactPadding;
  final double narrowPadding;
  final double mediumPadding;
  final double expandedPadding;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;

  double _horizontalPadding(double width) {
    if (width < AppBreakpoints.narrow) return narrowPadding;
    if (width < AppBreakpoints.compact) return compactPadding;
    if (width < AppBreakpoints.medium) return mediumPadding;
    return expandedPadding;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final horizontalPadding = _horizontalPadding(availableWidth);

        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding ??
                  EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
