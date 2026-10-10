import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/responsive_content.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/bader_adaptive_scaffold.dart';
import '../../core/widgets/bader_integrated_page_header.dart';
import '../../core/widgets/bader_page_safe_area.dart';

/// Branded fallback surface for contract/foundation routes that are retained
/// for route completeness but are not part of the primary product journey.
class FoundationFeatureView extends StatelessWidget {
  const FoundationFeatureView({
    super.key,
    required this.titleKey,
    required this.messageKey,
  });

  final String titleKey;
  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: titleKey.tr),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 680,
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  padding: context.responsive.pageInsets(
                    top: AppSpacing.xl,
                    bottom: AppSpacing.pageBottom,
                  ),
                  child: AppEmptyState(
                    icon: 'assets/icons/file-empty.png',
                    title: titleKey.tr,
                    message: messageKey.tr,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
