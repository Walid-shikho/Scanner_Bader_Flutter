import 'package:flutter/material.dart';

class ScrollFadeHeader extends StatelessWidget {
  const ScrollFadeHeader({
    super.key,
    required this.controller,
    required this.child,
    this.fadeStart = 0,
    this.fadeEnd = 190,
    this.translateDistance = 14,
  });

  final ScrollController controller;
  final Widget child;

  final double fadeStart;
  final double fadeEnd;

  final double translateDistance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final offset = controller.hasClients
            ? controller.offset
            : 0.0;

        final progress =
        ((offset - fadeStart) /
            (fadeEnd - fadeStart))
            .clamp(0.0, 1.0);

        final opacity = 1.0 - progress;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(
              0,
              -progress * translateDistance,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// يعمل Fade بصري في أسفل الخلفية.
///
/// ما فيه BackdropFilter أو GPU blur.
class BottomFadeMask extends StatelessWidget {
  const BottomFadeMask({
    super.key,
    required this.child,
    this.fadeStart = 0.74,
  });

  final Widget child;

  final double fadeStart;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [
            0,
            fadeStart,
            1,
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}