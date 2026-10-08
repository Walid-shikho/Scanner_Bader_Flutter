import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? AppColors.darkText : AppColors.textPrimary;
    final responsive = context.responsive;

    return BaderAdaptiveScaffold(
      body: BaderPageSafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: responsive.horizontalPagePadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/bader_logo.png',
                  width: responsive.responsiveDouble(
                    compact: 156,
                    medium: 176,
                    expanded: 196,
                  ),
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'app_name'.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.pageTitle.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
