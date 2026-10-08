import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../auth/app_mode.dart';
import '../../../routes/app_routes.dart';
import '../../home/views/home_view.dart';
import '../../partner/views/partner_view.dart';
import '../controllers/shell_controller.dart';
import '../widgets/shell_scan_fab.dart';

class ShellView extends StatefulWidget {
  const ShellView({super.key});

  @override
  State<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<ShellView> {
  late final ShellController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ShellController>();
  }

  @override
  Widget build(BuildContext context) {
    final activeMode = controller.activeMode;

    if (activeMode == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != AppRoutes.login) {
          Get.offAllNamed<void>(AppRoutes.login);
        }
      });

      return const BaderAdaptiveScaffold(
        usePageBackground: true,
        enableBlur: true,
        body: SizedBox.shrink(),
      );
    }

    if (activeMode == AppMode.partner) {
      return const BaderAdaptiveScaffold(
        usePageBackground: true,
        enableBlur: true,
        body: PartnerView(),
      );
    }

    final responsive = context.responsive;
    final keyboardVisible = responsive.keyboardVisible;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final fabBottom = bottomInset +
        (responsive.isNarrow ? AppSpacing.md : AppSpacing.lg) +
        AppSpacing.sm;
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      enableBlur: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: HomeView(),
            ),
          ),

          if (!keyboardVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: fabBottom,
              child: Center(
                child: ShellScanFab(
                  onPressed: controller.openScanFoundation,
                ),
              ),
            ),
        ],
      ),
    );
  }
}