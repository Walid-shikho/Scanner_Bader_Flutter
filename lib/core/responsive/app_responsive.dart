import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import '../theme/app_spacing.dart';

/// Immutable responsive snapshot for the current Flutter view.
///
/// Prefer sizing from the *available width* (LayoutBuilder) for reusable
/// components. This class intentionally keeps device names out of layout
/// decisions: compact/medium/expanded window classes work for phones,
/// tablets, desktop windows and split-screen panes alike.
@immutable
class AppResponsiveInfo {
  const AppResponsiveInfo({
    required this.size,
    required this.padding,
    required this.viewInsets,
    required this.textScale,
  });

  factory AppResponsiveInfo.of(BuildContext context) {
    final media = MediaQuery.of(context);
    return AppResponsiveInfo(
      size: media.size,
      padding: media.padding,
      viewInsets: media.viewInsets,
      textScale: media.textScaler.scale(1),
    );
  }

  final Size size;
  final EdgeInsets padding;
  final EdgeInsets viewInsets;
  final double textScale;

  double get width => size.width;
  double get height => size.height;
  double get shortestSide => size.shortestSide;
  double get longestSide => size.longestSide;

  AppWindowClass get windowClass => AppBreakpoints.windowClassFor(width);

  bool get isCompact => windowClass == AppWindowClass.compact;
  bool get isMedium => windowClass == AppWindowClass.medium;
  bool get isExpanded => windowClass == AppWindowClass.expanded;
  bool get isNarrow => width < AppBreakpoints.narrow;
  bool get isLandscape => width > height;
  bool get isPortrait => !isLandscape;
  bool get isTabletLike => shortestSide >= AppBreakpoints.compact;
  bool get keyboardVisible => viewInsets.bottom > 0;
  bool get largeText => textScale > 1.15;
  bool get veryLargeText => textScale > 1.35;

  double get horizontalPagePadding {
    if (width < 340) return 12;
    if (width < AppBreakpoints.narrow) return 14;
    if (isCompact) return 18;
    if (isMedium) return 28;
    return 36;
  }

  double get verticalPagePadding => isCompact ? 16 : 20;

  EdgeInsets pageInsets({double top = 0, double bottom = AppSpacing.pageBottom}) {
    return EdgeInsets.fromLTRB(
      horizontalPagePadding,
      top,
      horizontalPagePadding,
      bottom,
    );
  }

  EdgeInsets horizontalInsets({double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPagePadding,
      vertical: vertical,
    );
  }

  double get dialogHorizontalInset {
    if (width < 340) return 12;
    if (isCompact) return 18;
    if (isMedium) return 32;
    return 48;
  }

  double boundedWidth({
    required double maxWidth,
    double fraction = 1,
    double minWidth = 0,
  }) {
    final available = math.max(0.0, width * fraction);
    return available.clamp(minWidth, maxWidth).toDouble();
  }

  double dialogWidth({double maxWidth = 520, double fraction = .92}) {
    final available = math.max(0.0, width - (dialogHorizontalInset * 2));
    return math.min(maxWidth, math.min(available, width * fraction));
  }

  double responsiveDouble({
    required double compact,
    double? medium,
    double? expanded,
  }) {
    switch (windowClass) {
      case AppWindowClass.compact:
        return compact;
      case AppWindowClass.medium:
        return medium ?? compact;
      case AppWindowClass.expanded:
        return expanded ?? medium ?? compact;
    }
  }

  T responsiveValue<T>({
    required T compact,
    T? medium,
    T? expanded,
  }) {
    switch (windowClass) {
      case AppWindowClass.compact:
        return compact;
      case AppWindowClass.medium:
        return medium ?? compact;
      case AppWindowClass.expanded:
        return expanded ?? medium ?? compact;
    }
  }
}

extension AppResponsiveContext on BuildContext {
  AppResponsiveInfo get responsive => AppResponsiveInfo.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  double get textScale => MediaQuery.textScalerOf(this).scale(1);
  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  AppWindowClass get windowClass =>
      AppBreakpoints.windowClassFor(MediaQuery.sizeOf(this).width);
  bool get isCompact => windowClass == AppWindowClass.compact;
  bool get isMedium => windowClass == AppWindowClass.medium;
  bool get isExpanded => windowClass == AppWindowClass.expanded;
  bool get isNarrow => screenWidth < AppBreakpoints.narrow;
  bool get isLandscape => screenWidth > screenHeight;
  bool get isTabletLike => screenSize.shortestSide >= AppBreakpoints.compact;
  bool get keyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;
  bool get largeText => textScale > 1.15;
}
