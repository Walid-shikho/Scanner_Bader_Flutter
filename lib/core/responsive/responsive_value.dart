import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

T responsiveValue<T>(
  double availableWidth, {
  required T compact,
  T? medium,
  T? expanded,
}) {
  switch (AppBreakpoints.windowClassFor(availableWidth)) {
    case AppWindowClass.compact:
      return compact;
    case AppWindowClass.medium:
      return medium ?? compact;
    case AppWindowClass.expanded:
      return expanded ?? medium ?? compact;
  }
}

double responsiveDouble(
  double availableWidth, {
  required double compact,
  double? medium,
  double? expanded,
}) {
  return responsiveValue<double>(
    availableWidth,
    compact: compact,
    medium: medium,
    expanded: expanded,
  );
}

/// Gives reusable widgets the local constraints rather than forcing them to
/// size themselves from the full device width.
class AppResponsiveBuilder extends StatelessWidget {
  const AppResponsiveBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, BoxConstraints constraints) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }
}
