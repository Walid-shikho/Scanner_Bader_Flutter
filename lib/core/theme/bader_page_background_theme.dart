import 'package:flutter/material.dart';

/// Semantic colors for BADER's shared layered page background.
@immutable
class BaderPageBackgroundTheme
    extends ThemeExtension<BaderPageBackgroundTheme> {
  const BaderPageBackgroundTheme({
    required this.background,
    required this.accentStart,
    required this.accentMiddle,
    required this.accentEnd,
  });

  final Color background;
  final Color accentStart;
  final Color accentMiddle;
  final Color accentEnd;

  static BaderPageBackgroundTheme of(BuildContext context) {
    final value = Theme.of(context).extension<BaderPageBackgroundTheme>();
    assert(value != null, 'BaderPageBackgroundTheme is missing from ThemeData.');
    return value!;
  }

  @override
  BaderPageBackgroundTheme copyWith({
    Color? background,
    Color? accentStart,
    Color? accentMiddle,
    Color? accentEnd,
  }) {
    return BaderPageBackgroundTheme(
      background: background ?? this.background,
      accentStart: accentStart ?? this.accentStart,
      accentMiddle: accentMiddle ?? this.accentMiddle,
      accentEnd: accentEnd ?? this.accentEnd,
    );
  }

  @override
  BaderPageBackgroundTheme lerp(
    covariant BaderPageBackgroundTheme? other,
    double t,
  ) {
    if (other == null) return this;

    return BaderPageBackgroundTheme(
      background: Color.lerp(background, other.background, t)!,
      accentStart: Color.lerp(accentStart, other.accentStart, t)!,
      accentMiddle: Color.lerp(accentMiddle, other.accentMiddle, t)!,
      accentEnd: Color.lerp(accentEnd, other.accentEnd, t)!,
    );
  }
}
