import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'bader_adaptive_back_button.dart';

/// Header used by creation/search flows that need to feel like part of the
/// page instead of a separate rectangular app bar.
class BaderIntegratedPageHeader extends StatelessWidget {
  const BaderIntegratedPageHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? AppColors.darkText : AppColors.textPrimary;
    final horizontal = context.responsive.horizontalPagePadding;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        horizontal,
        0,
        horizontal,
        AppSpacing.sm,
      ),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: Center(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.pageTitle.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 0,
              child: BaderAdaptiveBackButton(
                onPressed: onBack ?? () => Get.back<void>(),
              ),
            ),
            if (trailing != null)
              PositionedDirectional(
                end: 0,
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
