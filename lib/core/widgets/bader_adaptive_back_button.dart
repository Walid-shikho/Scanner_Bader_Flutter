import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'bader_liquid_glass_control.dart';

class BaderAdaptiveBackButton extends StatelessWidget {
  const BaderAdaptiveBackButton({
    super.key,
    this.onPressed,
    this.size = controlSize,
    this.imageSize = arrowSize,
    this.asset,
    this.semanticLabel,
  });

  static const double controlSize = 44;
  static const double arrowSize = 24;

  static const String arabicAsset =
      'assets/icons/arrow-narrow-right-dashed.png';
  static const String ltrAsset =
      'assets/icons/arrow-narrow-left-dashed.png';

  final VoidCallback? onPressed;
  final double size;
  final double imageSize;
  final String? asset;
  final String? semanticLabel;

  static String assetFor(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? arabicAsset
        : ltrAsset;
  }

  @override
  Widget build(BuildContext context) {
    final callback = onPressed ?? () => Navigator.of(context).maybePop();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return BaderLiquidGlassControl(
      size: size,
      onPressed: callback,
      fallbackBackgroundColor:
          dark ? AppColors.glassDark : AppColors.glassLight,
      semanticLabel: semanticLabel ??
          MaterialLocalizations.of(context).backButtonTooltip,
      child: Image.asset(
        asset ?? assetFor(context),
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
        color: AppColors.primary,
      ),
    );
  }
}
