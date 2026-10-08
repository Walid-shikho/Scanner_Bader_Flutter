import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/responsive_content.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_fading_header.dart';
import '../../core/widgets/bader_icon_button.dart';
import '../../core/widgets/bader_page_safe_area.dart';

class ScannerRootPlaceholder extends StatelessWidget {
  const ScannerRootPlaceholder({
    super.key,
    required this.titleKey,
    required this.messageKey,
    required this.onSettings,
    this.actionLabelKey,
    this.onAction,
  });

  final String titleKey;
  final String messageKey;
  final VoidCallback onSettings;
  final String? actionLabelKey;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? AppColors.darkText : AppColors.textPrimary;
    final pagePadding = responsive.horizontalPagePadding;

    return BaderPageSafeArea(
      bottom: false,
      child: ResponsiveContent(
        maxWidth: 820,
        padding: EdgeInsets.zero,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AppFadingHeaderSliver(
              fadeDistance: responsive.isNarrow ? 104 : 120,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  pagePadding,
                  AppSpacing.md,
                  pagePadding,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          titleKey.tr,
                          maxLines: responsive.largeText ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.pageTitle.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    BaderIconButton(
                      icon: 'assets/icons/settings.png',
                      tooltip: 'settings'.tr,
                      onPressed: onSettings,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: pagePadding,
                ),
                child: AppEmptyState(
                  icon: 'assets/icons/file-empty.png',
                  title: 'phase2_placeholder_title'.tr,
                  message: messageKey.tr,
                  actionLabel: actionLabelKey?.tr,
                  onAction: onAction,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
