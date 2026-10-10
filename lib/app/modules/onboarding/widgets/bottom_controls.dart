part of '../views/onboarding_view.dart';

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.count,
    required this.current,
    required this.onNext,
    required this.compact,
  });

  final int count;

  final int current;

  final VoidCallback onNext;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,

      crossAxisAlignment:
      CrossAxisAlignment.center,

      mainAxisSize:
      MainAxisSize.min,

      textDirection:
      TextDirection.ltr,

      children: [
        _StepsIndicator(
          count:
          count,

          current:
          current,

          compact:
          compact,
        ),

        SizedBox(
          width:
          compact
              ? 8
              : 12,
        ),

        _NextArrowButton(
          onPressed:
          onNext,

          compact:
          compact,
        ),
      ],
    );
  }
}
