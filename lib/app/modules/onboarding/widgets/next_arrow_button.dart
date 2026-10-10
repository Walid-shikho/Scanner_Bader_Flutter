part of '../views/onboarding_view.dart';

class _NextArrowButton extends StatefulWidget {
  const _NextArrowButton({
    required this.onPressed,
    required this.compact,
  });

  final VoidCallback onPressed;

  final bool compact;

  @override
  State<_NextArrowButton> createState() =>
      _NextArrowButtonState();
}

class _NextArrowButtonState
    extends State<_NextArrowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double size =
    widget.compact
        ? 58
        : 70;

    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(
              () {
            _pressed = true;
          },
        );
      },

      onTapCancel: () {
        setState(
              () {
            _pressed = false;
          },
        );
      },

      onTapUp: (_) {
        setState(
              () {
            _pressed = false;
          },
        );

        widget.onPressed();
      },

      child: AnimatedScale(
        scale:
        _pressed
            ? .90
            : 1,

        duration:
        const Duration(
          milliseconds:
          110,
        ),

        curve:
        Curves.easeOut,

        child: SizedBox(
          width:
          size,

          height:
          size,

          child: Image.asset(
            AppAssets.onboardingNextArrow,
            fit: BoxFit.contain,
            cacheWidth: AppImageDecodeSize.width(context, size, max: 320),
            cacheHeight: AppImageDecodeSize.height(context, size, max: 320),
            filterQuality: FilterQuality.low,
          ),
        ),
      ),
    );
  }
}
