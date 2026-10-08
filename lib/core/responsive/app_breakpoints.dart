enum AppWindowClass {
  compact,
  medium,
  expanded,
}

abstract final class AppBreakpoints {
  /// Very small phones / split-screen compact panes.
  static const narrow = 360.0;

  /// Material 3 compact -> medium window-class boundary.
  static const compact = 600.0;

  /// Medium -> expanded window-class boundary.
  static const medium = 900.0;

  /// Wide desktop/tablet landscape content boundary.
  static const expanded = 1200.0;

  static AppWindowClass windowClassFor(double width) {
    if (width < compact) return AppWindowClass.compact;
    if (width < medium) return AppWindowClass.medium;
    return AppWindowClass.expanded;
  }
}
