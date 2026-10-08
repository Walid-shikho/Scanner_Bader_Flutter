import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_adaptive_tap_surface.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../../../core/widgets/language_selector_button.dart';
import '../../../auth/app_mode.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return BaderAdaptiveScaffold(
      usePageBackground: true,
      pageBackgroundAccentScale: 1.08,
      resizeToAvoidBottomInset: true,
      body: BaderPageSafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal =
            responsive.isNarrow ? AppSpacing.lg : AppSpacing.xxl;
            final compactHeight = constraints.maxHeight < 700;

            return Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                horizontal,
                AppSpacing.md,
                horizontal,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: compactHeight ? 60 : 70,
                        height: compactHeight ? 60 : 70,
                        child: Image.asset(
                          dark
                              ? 'assets/images/bader_logo_white.png'
                              : 'assets/images/bader_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Spacer(),
                      const LanguageSelectorButton(compact: true),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                          vertical:
                          compactHeight ? AppSpacing.md : AppSpacing.xl,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Container(
                            padding: EdgeInsets.all(
                              responsive.isNarrow
                                  ? AppSpacing.xl
                                  : AppSpacing.xxl,
                            ),
                            decoration: BoxDecoration(
                              color: dark
                                  ? AppColors.darkSurface.withValues(alpha: .94)
                                  : AppColors.surface.withValues(alpha: .96),
                              borderRadius:
                              BorderRadius.circular(AppRadius.xxl),
                              border: Border.all(
                                color: dark
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                              ),
                              boxShadow: AppShadows.card,
                            ),
                            child: Obx(() {
                              final selectedMode =
                                  controller.selectedMode.value;
                              final errorKey = controller.errorKey.value;
                              final loading = controller.loading.value;
                              final accent = selectedMode == AppMode.partner
                                  ? AppColors.primary
                                  : AppColors.secondary;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'login'.tr,
                                    style: AppTextStyles.headline.copyWith(
                                      color: dark
                                          ? AppColors.darkText
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'bader_product_family'.tr,
                                    style: AppTextStyles.body.copyWith(
                                      color: dark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  Text(
                                    'select_operating_mode'.tr,
                                    style: AppTextStyles.small.copyWith(
                                      color: dark
                                          ? AppColors.darkText
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  _ModeSelector(
                                    selectedMode: selectedMode,
                                    enabled: !loading,
                                    onSelected: controller.selectMode,
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  _LoginField(
                                    controller: controller.email,
                                    label: 'email'.tr,
                                    icon: 'assets/icons/user.png',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _LoginField(
                                    controller: controller.password,
                                    label: 'password'.tr,
                                    icon: 'assets/icons/shield-lock.png',
                                    obscureText:
                                    controller.obscurePassword.value,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) {
                                      if (!loading) controller.submit();
                                    },
                                    trailing: IconButton(
                                      tooltip: 'password'.tr,
                                      onPressed: loading
                                          ? null
                                          : controller
                                          .togglePasswordVisibility,
                                      icon: BaderAssetIcon(
                                        controller.obscurePassword.value
                                            ? 'assets/icons/eye.png'
                                            : 'assets/icons/eye-off.png',
                                        size: 20,
                                        color: dark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  if (errorKey != null) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      errorKey.tr,
                                      style: AppTextStyles.small.copyWith(
                                        color: AppColors.danger,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.lg),
                                  AppPrimaryButton(
                                    label: loading
                                        ? '${'login'.tr}...'
                                        : 'login'.tr,
                                    icon: Directionality.of(context) ==
                                        TextDirection.rtl
                                        ? 'assets/icons/login-left.png'
                                        : 'assets/icons/login-right.png',
                                    backgroundColor: accent,
                                    isLoading: false,
                                    onPressed:
                                    loading ? null : controller.submit,
                                  ),
                                  if (AppConfig.isOfflineDemo) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        BaderAssetIcon(
                                          'assets/icons/shield-lock.png',
                                          size: 17,
                                          color: dark
                                              ? AppColors.darkMuted
                                              : AppColors.muted,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            'offline_demo_login_hint'.tr,
                                            style: AppTextStyles.micro.copyWith(
                                              color: dark
                                                  ? AppColors.darkMuted
                                                  : AppColors.muted,
                                              height: 1.45,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selectedMode,
    required this.enabled,
    required this.onSelected,
  });

  final AppMode selectedMode;
  final bool enabled;
  final ValueChanged<AppMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final largeText = context.responsive.veryLargeText;

    if (largeText) {
      return Column(
        children: [
          _ModeOption(
            mode: AppMode.partner,
            selected: selectedMode == AppMode.partner,
            enabled: enabled,
            title: 'partner_manager_mode'.tr,
            icon: 'assets/icons/user-check.png',
            accent: AppColors.primary,
            onSelected: onSelected,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ModeOption(
            mode: AppMode.scanner,
            selected: selectedMode == AppMode.scanner,
            enabled: enabled,
            title: 'scanner_operator_mode'.tr,
            icon: 'assets/icons/qrcode.png',
            accent: AppColors.secondary,
            onSelected: onSelected,
          ),
        ],
      );
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final accent = selectedMode == AppMode.partner
        ? AppColors.primary
        : AppColors.secondary;
    final selectedAlignment = selectedMode == AppMode.partner
        ? (rtl ? Alignment.centerRight : Alignment.centerLeft)
        : (rtl ? Alignment.centerLeft : Alignment.centerRight);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface2 : AppColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: dark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: selectedAlignment,
            child: FractionallySizedBox(
              widthFactor: .5,
              heightFactor: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: dark ? .28 : .20),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _ModeSegmentContent(
                  mode: AppMode.partner,
                  selected: selectedMode == AppMode.partner,
                  enabled: enabled,
                  title: 'partner_manager_mode'.tr,
                  icon: 'assets/icons/user-check.png',
                  accent: AppColors.primary,
                  onSelected: onSelected,
                ),
              ),
              Expanded(
                child: _ModeSegmentContent(
                  mode: AppMode.scanner,
                  selected: selectedMode == AppMode.scanner,
                  enabled: enabled,
                  title: 'scanner_operator_mode'.tr,
                  icon: 'assets/icons/qrcode.png',
                  accent: AppColors.secondary,
                  onSelected: onSelected,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeSegmentContent extends StatelessWidget {
  const _ModeSegmentContent({
    required this.mode,
    required this.selected,
    required this.enabled,
    required this.title,
    required this.icon,
    required this.accent,
    required this.onSelected,
  });

  final AppMode mode;
  final bool selected;
  final bool enabled;
  final String title;
  final String icon;
  final Color accent;
  final ValueChanged<AppMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = selected
        ? Colors.white
        : (dark ? AppColors.darkTextSecondary : AppColors.textSecondary);

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: BaderAdaptiveTapSurface(
        onTap: enabled ? () => onSelected(mode) : null,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: selected ? 1 : .975,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // AnimatedContainer(
                //   duration: const Duration(milliseconds: 200),
                //   curve: Curves.easeOutCubic,
                //   width: 30,
                //   height: 30,
                //   decoration: BoxDecoration(
                //     color: selected
                //         ? Colors.white.withValues(alpha: .16)
                //         : accent.withValues(alpha: dark ? .14 : .09),
                //     borderRadius: BorderRadius.circular(AppRadius.md),
                //   ),
                //   child: Center(
                //     child: BaderAssetIcon(
                //       icon,
                //       size: 17,
                //       color: selected ? Colors.white : accent,
                //     ),
                //   ),
                // ),
                // const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style: AppTextStyles.small.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                      height: 1.15,
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
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

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.mode,
    required this.selected,
    required this.enabled,
    required this.title,
    required this.icon,
    required this.accent,
    required this.onSelected,
  });

  final AppMode mode;
  final bool selected;
  final bool enabled;
  final String title;
  final String icon;
  final Color accent;
  final ValueChanged<AppMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = selected
        ? accent
        : (dark ? AppColors.darkTextSecondary : AppColors.textSecondary);

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: BaderAdaptiveTapSurface(
        onTap: enabled ? () => onSelected(mode) : null,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: selected ? 1 : .985,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: dark ? .16 : .08)
                  : (dark ? AppColors.darkSurface2 : AppColors.surfaceHighlight),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: dark ? .65 : .42)
                    : (dark ? AppColors.darkBorder : AppColors.border),
                width: selected ? 1.4 : 1,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: accent.withValues(alpha: dark ? .12 : .08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: dark ? .18 : .10),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: BaderAssetIcon(icon, size: 18, color: accent),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: selected
                      ? Container(
                    key: const ValueKey('selected'),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  )
                      : const SizedBox(
                    key: ValueKey('unselected'),
                    width: 22,
                    height: 22,
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

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.trailing,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String icon;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
    dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autocorrect: false,
      enableSuggestions: !obscureText,
      style: AppTextStyles.body.copyWith(
        color: dark ? AppColors.darkText : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: BaderAssetIcon(icon, size: 20, color: secondary),
        ),
        suffixIcon: trailing,
      ),
    );
  }
}
