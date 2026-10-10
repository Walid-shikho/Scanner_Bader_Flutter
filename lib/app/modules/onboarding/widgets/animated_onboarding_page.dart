part of '../views/onboarding_view.dart';

class _AnimatedOnboardingPage extends StatefulWidget {
  const _AnimatedOnboardingPage({
    super.key,
    required this.active,
    required this.image,
    required this.title,
    required this.description,
    required this.compactHeight,
    required this.largeHeight,
  });

  final bool active;

  final String image;

  final String title;

  final String description;

  final bool compactHeight;

  final bool largeHeight;

  @override
  State<_AnimatedOnboardingPage> createState() =>
      _AnimatedOnboardingPageState();
}

class _AnimatedOnboardingPageState
    extends State<_AnimatedOnboardingPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  late final AnimationController _imageController;

  late final Animation<double> _imageAnimation;

  late final Animation<double> _titleAnimation;

  late final Animation<double> _descriptionAnimation;

  @override
  void initState() {
    super.initState();

    // ==============================================================
    // MAIN ANIMATION CONTROLLER
    // ==============================================================
    //
    // زيد هالقيمة إذا بدك الأنيميشن كله أبطأ.
    //

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2200,
      ),
    );

    // ==============================================================
    // IMAGE FADE ANIMATION
    // ==============================================================

    // The illustration has its own short controller so the fade feels soft
    // and modern without changing the existing title/description sequence.
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
      reverseDuration: const Duration(milliseconds: 360),
    );

    _imageAnimation = CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );

    // ==============================================================
    // TITLE
    // ==============================================================

    _titleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.12,
        0.48,
        curve: Curves.linear,
      ),
    );

    // ==============================================================
    // DESCRIPTION
    // ==============================================================

    _descriptionAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.60,
        1.00,
        curve: Curves.linear,
      ),
    );

    if (widget.active) {
      _controller.forward();
      _imageController.forward();
    }
  }

  @override
  void didUpdateWidget(
      covariant _AnimatedOnboardingPage oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    // دخلنا الصفحة
    if (widget.active && !oldWidget.active) {
      _controller.forward(
        from: 0,
      );
      _imageController.forward(from: 0);
    }

    // خرجنا من الصفحة
    if (!widget.active && oldWidget.active) {
      _controller.reset();
      _imageController.reverse();
    }

    // تغيرت اللغة
    if (widget.active &&
        (widget.title != oldWidget.title ||
            widget.description != oldWidget.description)) {
      _controller.forward(
        from: 0,
      );
      _imageController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool rtl =
        Get.locale?.languageCode == 'ar';
    final responsive = context.responsive;
    final narrow = responsive.isNarrow;
    final largeText = responsive.largeText;

    return Directionality(
      textDirection:
      rtl ? TextDirection.rtl : TextDirection.ltr,

      child: Padding(
        padding: EdgeInsets.fromLTRB(
          narrow ? AppSpacing.md : (widget.compactHeight ? AppSpacing.lg : AppSpacing.xl),

          widget.compactHeight ? AppSpacing.xs : AppSpacing.md,

          narrow ? AppSpacing.md : (widget.compactHeight ? AppSpacing.lg : AppSpacing.xl),

          // مساحة للـ indicator والسهم
          widget.compactHeight ? 72 : 90,
        ),

        child: Column(
          children: [
            // ========================================================
            // ILLUSTRATION
            // ========================================================

            Expanded(
              flex:
              widget.compactHeight ? 58 : 62,

              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: narrow
                        ? 330
                        : widget.largeHeight
                            ? 420
                            : 390,
                  ),

                  child: _AssembleIllustration(
                    image: widget.image,

                    animation:
                    _imageAnimation,
                  ),
                ),
              ),
            ),

            SizedBox(
              height:
              widget.compactHeight
                  ? 4
                  : 8,
            ),

            // ========================================================
            // TITLE
            // ========================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: narrow ? AppSpacing.md : AppSpacing.xl,
              ),

              child: _TypewriterText(
                text:
                widget.title,

                animation:
                _titleAnimation,

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  color:
                  const Color(0xFF202426),

                  fontSize: largeText
                      ? (widget.compactHeight ? AppTextStyles.titleSize : AppTextStyles.headlineSize)
                      : (widget.compactHeight ? AppTextStyles.pageTitleSize : AppTextStyles.displaySize),

                  height:
                  1.16,

                  fontWeight:
                  FontWeight.w900,

                  letterSpacing:
                  -0.45,
                ),
              ),
            ),

            SizedBox(
              height:
              widget.compactHeight
                  ? 7
                  : 10,
            ),

            // ========================================================
            // DESCRIPTION
            // ========================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: narrow ? AppSpacing.lg : AppSpacing.xxxl,
              ),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: narrow ? 300 : 355,
                ),

                child: _TypewriterText(
                  text:
                  widget.description,

                  animation:
                  _descriptionAnimation,

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(
                    color:
                    const Color(
                      0xFF7D8587,
                    ),

                    fontSize: largeText
                        ? (widget.compactHeight ? AppTextStyles.captionSize : AppTextStyles.labelSize)
                        : (widget.compactHeight ? AppTextStyles.captionSize : AppTextStyles.smallSize),

                    height:
                    1.55,

                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
            ),

            const Spacer(
              flex: 5,
            ),
          ],
        ),
      ),
    );
  }
}
