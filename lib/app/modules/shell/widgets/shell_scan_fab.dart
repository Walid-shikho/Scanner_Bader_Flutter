import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_liquid_glass_control.dart';

/// Scanner Partner's shell-level primary Scan action.
///
/// Its visual treatment intentionally mirrors the Bader-family FAB used by the
/// sibling applications; QR verification/redemption behavior remains owned by
/// the existing Scanner flow.
class ShellScanFab extends StatelessWidget {
  const ShellScanFab({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final liquid = PlatformInfo.isIOS26OrHigher();
    final label = 'scan_qr'.tr;

    return RepaintBoundary(
      child: Tooltip(
        message: label,
        child: liquid
            ? BaderLiquidGlassControl(
                size: 56,
                onPressed: onPressed,
                prominent: true,
                tintColor: AppColors.secondary,
                semanticLabel: label,
                child: const BaderAssetIcon(
                  'assets/icons/scan.png',
                  size: 27,
                  color: Colors.white,
                ),
              )
            : FloatingActionButton(
                heroTag: 'scannerShellScanFab',
                onPressed: onPressed,
                elevation: 3,
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                tooltip: label,
                shape: const CircleBorder(),
                child: const BaderAssetIcon(
                  'assets/icons/scan.png',
                  size: 27,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
