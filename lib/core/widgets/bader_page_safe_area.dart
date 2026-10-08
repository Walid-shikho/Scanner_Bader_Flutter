import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Internal page-chrome state shared by [BaderAdaptiveScaffold] and
/// [BaderPageSafeArea].
///
/// Standard screens do not need to read this directly. It lets the safe-area
/// policy know when modern iOS is using Bader's integrated edge-to-edge header
/// instead of a full-width native toolbar surface.
class BaderPageChromeScope extends InheritedWidget {
  const BaderPageChromeScope({
    super.key,
    required this.integratedAppBar,
    required super.child,
  });

  final bool integratedAppBar;

  static BaderPageChromeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BaderPageChromeScope>();
  }

  @override
  bool updateShouldNotify(BaderPageChromeScope oldWidget) {
    return integratedAppBar != oldWidget.integratedAppBar;
  }
}

/// Canonical vertical safe-area policy for ordinary Bader page content.
///
/// Page without an app bar:
///   system safe top + [AppSpacing.pageTop].
///
/// Page below a normal platform app bar:
///   the app bar owns the system inset; this widget adds only
///   [AppSpacing.pageTop].
///
/// Page below the integrated/overlay app bar:
///   background stays edge-to-edge while interactive content starts after
///   system safe top + toolbar extent + [AppSpacing.pageTop].
class BaderPageSafeArea extends StatelessWidget {
  const BaderPageSafeArea({
    super.key,
    required this.child,
    this.appBarHandled = false,
    this.appBarOverlay = false,
    this.bottom = true,
    this.applyTopSpacing = true,
  });

  final Widget child;
  final bool appBarHandled;
  final bool appBarOverlay;
  final bool bottom;
  final bool applyTopSpacing;

  static double toolbarExtentOf(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return 44.0;
    }
    return kToolbarHeight;
  }

  static bool _usesIntegratedAppBar(BuildContext context) {
    return BaderPageChromeScope.maybeOf(context)?.integratedAppBar ?? false;
  }

  static double topInsetOf(
    BuildContext context, {
    bool appBarHandled = false,
    bool appBarOverlay = false,
    bool includeContentSpacing = true,
  }) {
    final contentSpacing =
        includeContentSpacing ? AppSpacing.pageTop : 0.0;
    final integrated = _usesIntegratedAppBar(context);
    final overlay = appBarOverlay || (appBarHandled && integrated);

    if (overlay) {
      return MediaQuery.viewPaddingOf(context).top +
          toolbarExtentOf(context) +
          contentSpacing;
    }

    final systemInset =
        appBarHandled ? 0.0 : MediaQuery.viewPaddingOf(context).top;
    return systemInset + contentSpacing;
  }

  @override
  Widget build(BuildContext context) {
    final integrated = _usesIntegratedAppBar(context);
    final overlay = appBarOverlay || (appBarHandled && integrated);
    final overlayTop = overlay
        ? MediaQuery.viewPaddingOf(context).top + toolbarExtentOf(context)
        : 0.0;

    return SafeArea(
      top: !appBarHandled && !overlay,
      bottom: bottom,
      left: false,
      right: false,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Padding(
          padding: EdgeInsets.only(
            top: overlayTop +
                (applyTopSpacing ? AppSpacing.pageTop : 0.0),
          ),
          child: child,
        ),
      ),
    );
  }
}
