import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../localization/app_locale_service.dart';
import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'bader_asset_icon.dart';

class LanguageSelectorButton extends StatelessWidget {
  const LanguageSelectorButton({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final localeService =
    Get.find<AppLocaleService>();

    return Obx(() {
      final languageCode =
          localeService.locale.value.languageCode;

      final entries =
      <AdaptivePopupMenuEntry>[
        _languageItem(
          value: 'ar',
          label: 'العربية',
          selected:
          languageCode == 'ar',
        ),
        _languageItem(
          value: 'en',
          label: 'English',
          selected:
          languageCode == 'en',
        ),
        _languageItem(
          value: 'de',
          label: 'Deutsch',
          selected:
          languageCode == 'de',
        ),
      ];

      return AdaptivePopupMenuButton.widget<String>(
        items: entries,
        tint: AppColors.primary,
        buttonStyle:
        PopupButtonStyle.glass,

        onSelected: (_, entry) {
          final value =
              entry.value;

          if (value != null) {
            localeService.changeLanguage(
              value,
            );
          }
        },

        child: _LanguageButtonContent(
          languageCode:
          languageCode,
          compact:
          compact,
        ),
      );
    });
  }

  AdaptivePopupMenuItem<String> _languageItem({
    required String value,
    required String label,
    required bool selected,
  }) {
    return AdaptivePopupMenuItem<String>(
      value: value,
      label: label,
      icon: selected
          ? PlatformInfo.isIOS26OrHigher()
          ? 'checkmark.circle.fill'
          : Icons.check_circle_rounded
          : PlatformInfo.isIOS26OrHigher()
          ? 'globe'
          : Icons.language_rounded,
    );
  }
}

class _LanguageButtonContent
    extends StatelessWidget {
  const _LanguageButtonContent({
    required this.languageCode,
    required this.compact,
  });

  final String languageCode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final data =
    _languageData(languageCode);

    final dark =
        Theme.of(context).brightness ==
            Brightness.dark;
    final nativeGlass = PlatformInfo.isIOS26OrHigher();

    final responsive =
        context.responsive;

    final baseHeight =
    compact ? 40.0 : 46.0;

    final effectiveHeight =
    responsive.veryLargeText
        ? baseHeight + 10
        : responsive.largeText
        ? baseHeight + 6
        : baseHeight;

    final backgroundColor = dark
        ? AppColors.darkSurface2
        : AppColors.surfaceElevated;

    final borderColor = dark
        ? AppColors.darkBorder
        : AppColors.border;

    final textColor = dark
        ? AppColors.darkText
        : AppColors.textPrimary;

    final secondaryColor = dark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Semantics(
      button: true,
      label: data.label,
      child: Container(
        constraints:
        BoxConstraints(
          minHeight:
          effectiveHeight,
        ),
        padding:
        EdgeInsetsDirectional.symmetric(
          horizontal: compact
              ? AppSpacing.md
              : AppSpacing.lg,
        ),
        decoration: nativeGlass
            ? null
            : BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: borderColor,
                  width: .9,
                ),
              ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment:
              Alignment.center,
              decoration:
              BoxDecoration(
                color: dark
                    ? AppColors.primarySoftDark
                    : AppColors.primarySoft,
                shape:
                BoxShape.circle,
              ),
              child:
              const BaderAssetIcon(
                'assets/icons/language.png',
                size: 18,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Flexible(
              child: Text(
                data.label,
                maxLines:
                responsive.largeText
                    ? 2
                    : 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                AppTextStyles.small.copyWith(
                  color:
                  textColor,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              color:
              secondaryColor,
              size:
              19,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageData {
  const _LanguageData({
    required this.label,
  });

  final String label;
}

_LanguageData _languageData(
    String code,
    ) {
  return switch (code) {
    'en' =>
    const _LanguageData(
      label: 'English',
    ),
    'de' =>
    const _LanguageData(
      label: 'Deutsch',
    ),
    _ =>
    const _LanguageData(
      label: 'العربية',
    ),
  };
}
