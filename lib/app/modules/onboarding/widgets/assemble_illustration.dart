part of '../views/onboarding_view.dart';

class _AssembleIllustration extends StatelessWidget {
  const _AssembleIllustration({
    required this.image,
    required this.animation,
  });

  final String image;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final logicalWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : 390.0;
          final logicalHeight = logicalWidth / (561 / 701);

          return AspectRatio(
            aspectRatio: 561 / 701,
            child: FadeTransition(
              opacity: animation,
              child: Image.asset(
                image,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                cacheWidth: AppImageDecodeSize.width(
                  context,
                  logicalWidth,
                  max: 1200,
                ),
                cacheHeight: AppImageDecodeSize.height(
                  context,
                  logicalHeight,
                  max: 1600,
                ),
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
