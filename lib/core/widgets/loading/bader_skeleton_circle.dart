import 'package:flutter/material.dart';

import 'bader_shimmer.dart';

class BaderSkeletonCircle extends StatelessWidget {
  const BaderSkeletonCircle({
    super.key,
    required this.diameter,
  });

  final double diameter;

  @override
  Widget build(BuildContext context) {
    final inherited = BaderSkeletonPalette.maybeOf(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = inherited?.baseColor ?? BaderSkeletonColors.base(dark: dark);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
