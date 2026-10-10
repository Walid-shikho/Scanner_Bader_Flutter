part of '../views/onboarding_view.dart';

class _StepsIndicator extends StatelessWidget {
  const _StepsIndicator({
    required this.count,
    required this.current,
    required this.compact,
  });

  final int count;

  final int current;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final List<double> widths =
    compact
        ? const [
      16,
      27,
      40,
    ]
        : const [
      20,
      34,
      50,
    ];

    return Row(
      mainAxisSize:
      MainAxisSize.min,

      mainAxisAlignment:
      MainAxisAlignment.center,

      textDirection:
      TextDirection.ltr,

      children: List.generate(
        count,
            (
            index,
            ) {
          final bool selected =
              index ==
                  current;

          final double width =
          index <
              widths.length
              ? widths[
          index]
              : widths
              .last;

          return AnimatedContainer(
            duration:
            const Duration(
              milliseconds:
              280,
            ),

            curve:
            Curves.easeOutCubic,

            margin:
            const EdgeInsets
                .symmetric(
              horizontal:
              4,
            ),

            width:
            width,

            height:
            compact
                ? 5
                : 6,

            decoration:
            BoxDecoration(
              color:
              selected
                  ? AppColors
                  .secondary
                  : AppColors
                  .borderStrong
                  .withValues(
                alpha:
                .38,
              ),

              borderRadius:
              BorderRadius.circular(
                100,
              ),
            ),
          );
        },
      ),
    );
  }
}
