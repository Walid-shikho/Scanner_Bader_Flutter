part of '../views/onboarding_view.dart';

class _TypewriterText extends StatelessWidget {
  const _TypewriterText({
    required this.text,
    required this.animation,
    required this.style,
    required this.textAlign,
  });

  final String text;

  final Animation<double> animation;

  final TextStyle style;

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    // characters أفضل للعربي والـ Unicode
    final List<String> chars =
    text.characters.toList();

    return AnimatedBuilder(
      animation:
      animation,

      builder: (
          context,
          _,
          ) {
        final int count =
        (chars.length *
            animation.value)
            .round()
            .clamp(
          0,
          chars.length,
        );

        final String visibleText =
        chars
            .take(count)
            .join();

        return Stack(
          alignment:
          Alignment.center,

          children: [
            // نحجز حجم النص النهائي من البداية
            Opacity(
              opacity:
              0,

              child: Text(
                text,

                textAlign:
                textAlign,

                style:
                style,
              ),
            ),

            Positioned.fill(
              child: Align(
                alignment:
                Alignment.center,

                child: Text(
                  visibleText,

                  textAlign:
                  textAlign,

                  style:
                  style,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
