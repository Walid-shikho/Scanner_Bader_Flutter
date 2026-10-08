import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bader_adaptive_dialog.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../../../core/widgets/language_selector_button.dart';
import '../../../auth/app_mode.dart';
import '../../../models/scanner_partner_models.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/widgets/home_dashboard_sections.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_section_title.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_option_button.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      title: 'settings'.tr,
      body: BaderPageSafeArea(
        appBarHandled: true,
        child: ResponsiveContent(
          padding: EdgeInsets.zero,
          maxWidth: 680,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: context.responsive.pageInsets(top: 0, bottom: 36),
            children: [
              SettingsSectionTitle('appearance'.tr),
              SettingsCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Obx(() {
                      final currentMode = controller.themeMode.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'theme_mode'.tr,
                            style: AppTextStyles.small.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkText
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final stackOptions = constraints.maxWidth < 390 ||
                                  context.responsive.largeText;
                              final options = <Widget>[
                                ThemeOptionButton(
                                  label: 'theme_system'.tr,
                                  icon: 'assets/icons/sun-moon.png',
                                  selected: currentMode == ThemeMode.system,
                                  onTap: () => controller.setTheme(ThemeMode.system),
                                ),
                                ThemeOptionButton(
                                  label: 'theme_light'.tr,
                                  icon: 'assets/icons/sun.png',
                                  selected: currentMode == ThemeMode.light,
                                  onTap: () => controller.setTheme(ThemeMode.light),
                                ),
                                ThemeOptionButton(
                                  label: 'theme_dark'.tr,
                                  icon: 'assets/icons/moon.png',
                                  selected: currentMode == ThemeMode.dark,
                                  onTap: () => controller.setTheme(ThemeMode.dark),
                                ),
                              ];

                              if (stackOptions) {
                                return Column(
                                  children: [
                                    for (var i = 0; i < options.length; i++) ...[
                                      options[i],
                                      if (i != options.length - 1)
                                        const SizedBox(height: AppSpacing.sm),
                                    ],
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: options[0]),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(child: options[1]),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(child: options[2]),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SettingsSectionTitle('language'.tr),
              const SettingsCard(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: LanguageSelectorButton(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Obx(() {
                final activeMode = controller.activeMode.value;
                if (activeMode != AppMode.scanner ||
                    !Get.isRegistered<HomeController>()) {
                  return const SizedBox.shrink();
                }

                final homeController = Get.find<HomeController>();
                final scannerContext = homeController.scannerContext.value;
                final state = homeController.state.value;
                final switching = homeController.isSwitchingBranch.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsSectionTitle('scanner_context'.tr),
                    if (scannerContext == null)
                      SettingsCard(
                        children: [
                          SettingsTile(
                            icon: 'assets/icons/qrcode.png',
                            title: 'scanner_context'.tr,
                            subtitle: state == HomeDashboardState.loading
                                ? 'loading'.tr
                                : 'home_server_error_message'.tr,
                            value: state == HomeDashboardState.loading
                                ? null
                                : 'retry'.tr,
                            onTap: state == HomeDashboardState.loading
                                ? null
                                : homeController.loadDashboard,
                            showChevron: false,
                          ),
                        ],
                      )
                    else
                      _ScannerContextSettingsCard(
                        contextData: scannerContext,
                        switching: switching,
                        onSelectBranch: () => _showBranchPicker(
                          context,
                          homeController,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                );
              }),
              SettingsSectionTitle('operating_mode'.tr),
              SettingsCard(
                children: [
                  Obx(() {
                    final activeMode = controller.activeMode.value;
                    return SettingsTile(
                      icon: 'assets/icons/user-check.png',
                      title: 'current_mode'.tr,
                      subtitle: 'offline_mode_switch_hint'.tr,
                      value: activeMode == null
                          ? 'select_operating_mode'.tr
                          : (activeMode.appCode == 'partner'
                              ? 'partner_manager_mode'.tr
                              : 'scanner_operator_mode'.tr),
                      showChevron: false,
                    );
                  }),
                  const Divider(height: 1),
                  Obx(
                    () => SettingsTile(
                      icon: 'assets/icons/chevron-right.png',
                      title: controller.destinationMode.appCode == 'partner'
                          ? 'switch_to_partner'.tr
                          : 'switch_to_scanner'.tr,
                      subtitle: 'mode_switch_visual_hint'.tr,
                      value: 'switch_mode_action'.tr,
                      onTap: controller.switchMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SettingsSectionTitle('app_information'.tr),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: 'assets/icons/qrcode.png',
                    title: 'app_name'.tr,
                    subtitle: 'bader_product_family'.tr,
                    value: 'scanner_partner_product'.tr,
                    showChevron: false,
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: 'assets/icons/versions.png',
                    title: 'app_version'.tr,
                    value: AppConfig.appVersion,
                    showChevron: false,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBranchPicker(
    BuildContext context,
    HomeController homeController,
  ) async {
    final branches = homeController.scannerBranches.toList(growable: false);
    final selected = await BaderAdaptiveDialog.show<PartnerBranchData?>(
      context: context,
      title: 'select_branch'.tr,
      content: HomeBranchPickerContent(
        branches: branches,
        selectedBranchPublicId:
            homeController.scannerContext.value?.branch?.publicId,
      ),
      actions: [
        BaderAdaptiveDialogAction<PartnerBranchData?>(
          label: 'cancel'.tr,
          result: null,
        ),
      ],
    );

    if (selected != null) {
      await homeController.selectBranch(selected);
    }
  }
}

class _ScannerContextSettingsCard extends StatelessWidget {
  const _ScannerContextSettingsCard({
    required this.contextData,
    required this.switching,
    required this.onSelectBranch,
  });

  final ScannerContextData contextData;
  final bool switching;
  final VoidCallback onSelectBranch;

  @override
  Widget build(BuildContext context) {
    final branch = contextData.branch;
    final device = contextData.scannerDevice;
    final branchName = branch == null
        ? 'no_selected_branch'.tr
        : _scannerBranchName(context, branch);
    final address = branch?.location?.address?.trim();
    final trust = device?.trustLevel?.trim().toLowerCase();
    final deviceValue = device == null
        ? 'scanner_device_unavailable'.tr
        : trust == 'trusted'
            ? 'trust_trusted'.tr
            : 'scanner_device_available'.tr;

    return SettingsCard(
      children: [
        SettingsTile(
          icon: 'assets/icons/map-pin.png',
          title: 'current_branch'.tr,
          subtitle: address?.isNotEmpty == true
              ? address
              : (branch == null ? 'no_selected_branch_message'.tr : null),
          value: switching ? 'loading'.tr : branchName,
          onTap: switching ? null : onSelectBranch,
        ),
        const Divider(height: 1),
        SettingsTile(
          icon: 'assets/icons/shield-lock.png',
          title: 'scanner_device'.tr,
          subtitle: device == null
              ? 'scanner_device_unavailable'.tr
              : 'scanner_device_available'.tr,
          value: deviceValue,
          showChevron: false,
        ),
      ],
    );
  }
}

String _scannerBranchName(BuildContext context, PartnerBranchData branch) {
  final languageCode = Localizations.localeOf(context).languageCode;
  if (languageCode == 'ar') return branch.nameAr;
  final translated = branch.nameEn?.trim();
  return translated == null || translated.isEmpty ? branch.nameAr : translated;
}
