import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/performance/image_decode_size.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/language_selector_button.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/onboarding_controller.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
part '../widgets/animated_onboarding_page.dart';
part '../widgets/assemble_illustration.dart';
part '../widgets/bottom_controls.dart';
part '../widgets/next_arrow_button.dart';
part '../widgets/steps_indicator.dart';
part '../widgets/typewriter_text.dart';

// ============================================================================
// ONBOARDING VIEW
// ============================================================================

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  static const List<String> _images = [
    'assets/images/onboarding/onboarding_1.png',
    'assets/images/onboarding/onboarding_2.png',
    'assets/images/onboarding/onboarding_3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: false,
      backgroundColor: Colors.white,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            // ========================================================
            // HEADER
            // ========================================================

            Padding(
              padding: EdgeInsets.fromLTRB(
                context.responsive.horizontalPagePadding,
                context.responsive.isNarrow ? AppSpacing.xs : AppSpacing.sm,
                context.responsive.horizontalPagePadding,
                0,
              ),
              child: Row(
                children: [
                  const LanguageSelectorButton(
                    compact: true,
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: controller.skip,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6E7476),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text(
                      'skip'.tr,
                      style: const TextStyle(
                        fontSize: AppTextStyles.labelSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // PAGES
            // ========================================================

            Expanded(
              child: LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  final bool compactHeight =
                      constraints.maxHeight < 620;

                  final bool largeHeight =
                      constraints.maxHeight > 820;

                  return Stack(
                    children: [
                      // ==================================================
                      // PAGE VIEW
                      // ==================================================

                      Positioned.fill(
                        child: Directionality(
                          // حركة الصفحات ثابتة مهما كانت اللغة
                          textDirection: TextDirection.ltr,

                          child: PageView.builder(
                            controller: controller.pageController,

                            itemCount: controller.pages.length,

                            physics: const BouncingScrollPhysics(),

                            onPageChanged: controller.onPageChanged,

                            itemBuilder: (
                                context,
                                index,
                                ) {
                              final item =
                              controller.pages[index];

                              return Obx(
                                    () => _AnimatedOnboardingPage(
                                  key: ValueKey(
                                    'onboarding_page_$index',
                                  ),

                                  active:
                                  controller.index.value == index,

                                  image: index < _images.length
                                      ? _images[index]
                                      : _images.first,

                                  title: item.title.tr,

                                  description:
                                  item.description.tr,

                                  compactHeight:
                                  compactHeight,

                                  largeHeight:
                                  largeHeight,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // ==================================================
                      // INDICATOR + NEXT ARROW
                      // ==================================================

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: compactHeight ? 5 : 12,

                        child: Obx(
                              () => Directionality(
                            textDirection: TextDirection.ltr,

                            child: _BottomControls(
                              count: controller.pages.length,

                              current:
                              controller.index.value,

                              onNext:
                              controller.next,

                              compact:
                              compactHeight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PAGE
// ============================================================================



// ============================================================================
// IMAGE ASSEMBLY ANIMATION
// ============================================================================


// ============================================================================
// INDIVIDUAL IMAGE PIECE
// ============================================================================


// ============================================================================
// NORMALIZED CLIPPER
// ============================================================================


// ============================================================================
// TYPEWRITER TEXT
// ============================================================================


// ============================================================================
// BOTTOM CONTROLS
// ============================================================================


// ============================================================================
// ORIGINAL STEP INDICATOR
// ============================================================================


// ============================================================================
// NEXT ARROW
// ============================================================================
