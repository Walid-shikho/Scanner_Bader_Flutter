import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../partner/widgets/partner_management_sections.dart';
import '../controllers/scanner_devices_controller.dart';

class ScannerDevicesView extends GetView<ScannerDevicesController> {
  const ScannerDevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'scanner_devices'.tr),
            Expanded(
              child: Obx(() {
                final state = controller.state.value;
                if (state == ScannerDevicesState.loading &&
                    controller.devices.isEmpty) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }
                if (state == ScannerDevicesState.permissionDenied) {
                  return AppEmptyState(
                    title: 'permission_denied'.tr,
                    message: 'scanner_devices_permission_denied'.tr,
                  );
                }
                if (state == ScannerDevicesState.error) {
                  return AppEmptyState(
                    title: 'error'.tr,
                    message: 'scanner_devices_load_error'.tr,
                    actionLabel: 'retry'.tr,
                    onAction: controller.load,
                  );
                }
                if (controller.devices.isEmpty) {
                  return AppEmptyState(
                    title: 'scanner_devices_empty'.tr,
                    message: 'scanner_devices_empty_message'.tr,
                  );
                }
                return ResponsiveContent(
                  maxWidth: 720,
                  padding: context.responsive.pageInsets(
                    top: AppSpacing.sm,
                    bottom: 0,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.pageBottom,
                    ),
                    itemCount: controller.devices.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return ScannerDeviceCard(
                        device: controller.devices[index],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
