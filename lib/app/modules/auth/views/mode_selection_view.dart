import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../routes/app_routes.dart';

/// Compatibility-only route retained for old links/builds.
/// Normal startup and mode switching now use the unified Login screen.
class ModeSelectionView extends StatefulWidget {
  const ModeSelectionView({super.key});

  @override
  State<ModeSelectionView> createState() => _ModeSelectionViewState();
}

class _ModeSelectionViewState extends State<ModeSelectionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.offAllNamed<void>(AppRoutes.login, arguments: Get.arguments);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const BaderAdaptiveScaffold(
      usePageBackground: true,
      enableBlur: true,
      body: SizedBox.shrink(),
    );
  }
}
