import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../../../core/widgets/language_selector_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BaderAdaptiveScaffold(
      usePageBackground: false,
      backgroundColor: Colors.white,
      body: BaderPageSafeArea(
        bottom: true,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                responsive.horizontalPagePadding,
                AppSpacing.xs,
                responsive.horizontalPagePadding,
                0,
              ),
              child: Row(
                children: [
                  const LanguageSelectorButton(compact: true),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.skip,
                    child: Text(
                      'skip'.tr,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.pages.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return Obx(() {
                    final active = controller.index.value == index;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPagePadding,
                      ),
                      child: Column(
                        children: [
                          const Spacer(flex: 1),
                          Expanded(
                            flex: 7,
                            child: AnimatedOpacity(
                              opacity: active ? 1 : .55,
                              duration: const Duration(milliseconds: 360),
                              curve: Curves.easeOutCubic,
                              child: AnimatedScale(
                                scale: active ? 1 : .94,
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeOutBack,
                                child: Image.asset(
                                  page.imageAsset,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AnimatedOpacity(
                            opacity: active ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              page.titleKey.tr,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.pageTitle.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AnimatedOpacity(
                            opacity: active ? 1 : 0,
                            duration: const Duration(milliseconds: 420),
                            child: Text(
                              page.descriptionKey.tr,
                              textAlign: TextAlign.center,
                              maxLines: responsive.largeText ? 5 : 4,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.55,
                              ),
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                responsive.horizontalPagePadding,
                AppSpacing.sm,
                responsive.horizontalPagePadding,
                AppSpacing.md,
              ),
              child: Obx(() {
                final current = controller.index.value;
                final last = current == controller.pages.length - 1;
                return Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(
                          controller.pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            width: index == current ? 28 : 8,
                            height: 8,
                            margin: const EdgeInsetsDirectional.only(
                              end: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: index == current
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: .18),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Semantics(
                      button: true,
                      label: last ? 'get_started'.tr : 'next'.tr,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        onTap: controller.next,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          height: 54,
                          padding: EdgeInsets.symmetric(
                            horizontal: last ? AppSpacing.xl : AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: last
                                ? AppColors.secondary
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (last) ...[
                                Text(
                                  'get_started'.tr,
                                  style: AppTextStyles.bodyBold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                              ],
                              Image.asset(
                                Directionality.of(context) == TextDirection.rtl
                                    ? 'assets/icons/chevron-left.png'
                                    : 'assets/icons/chevron-right.png',
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
