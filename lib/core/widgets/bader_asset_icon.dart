import 'package:flutter/material.dart';

/// Lightweight wrapper for Bader's PNG icon set.
///
/// It keeps sizing, tinting, semantics and BoxFit behavior consistent without
/// modifying the source assets themselves.
class BaderAssetIcon extends StatelessWidget {
  const BaderAssetIcon(
    this.asset, {
    super.key,
    this.size = 20,
    this.width,
    this.height,
    this.color,
    this.opacity = 1,
    this.semanticLabel,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final String asset;
  final double size;
  final double? width;
  final double? height;
  final Color? color;
  final double opacity;
  final String? semanticLabel;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? IconTheme.of(context).color;
    final image = Image.asset(
      asset,
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      alignment: alignment,
      color: effectiveColor,
      colorBlendMode: effectiveColor == null ? null : BlendMode.srcIn,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      filterQuality: FilterQuality.medium,
    );

    if (opacity >= 1) return image;

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0).toDouble(),
      child: image,
    );
  }
}
