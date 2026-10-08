import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'bader_asset_icon.dart';
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint,
    this.hintWidget,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.readOnly = true,
    this.showFilter = true,
    this.autofocus = false,
    this.suffixIcon,
    this.height = 58,
    this.borderRadius = 22,
  });

  final TextEditingController? controller;

  final String? hint;
  final Widget? hintWidget;

  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool readOnly;
  final bool showFilter;
  final bool autofocus;
  final Widget? suffixIcon;

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final placeholder =
        hint ?? 'search'.tr;

    final surface = dark
        ? AppColors.darkSurfaceElevated
        : Colors.white;

    final textColor = dark
        ? AppColors.darkText
        : AppColors.textPrimary;

    final muted = dark
        ? AppColors.darkMuted
        : const Color(0xFF9299A5);
    Widget buildSearchIcon() {
      return SizedBox(
        width: 42,
        height: 42,
        child: Center(
          child: Image.asset(
            'assets/icons/search.png',
            width: 26,
            // height: 16,
            color: muted,
          ),
        ),
      );
    }

    Widget? buildFilterIcon() {
      if (!showFilter) {
        return null;
      }

      return GestureDetector(
        onTap: onFilterTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 42,
          height: 42,
          margin:
          const EdgeInsets.all(AppSpacing.sm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dark
                ? AppColors.darkSurface
                : AppColors.primarySoft,
            borderRadius:
            BorderRadius.circular(
              AppRadius.md,
            ),
          ),
          child: const BaderAssetIcon('assets/icons/settings.png',
            size: 20,
            color: AppColors.primary,
          ),
        ),
      );
    }

    final hintStyle = AppTextStyles.input.copyWith(
      color: muted,
      height: 1.1,
      fontWeight: FontWeight.w400,
    );

    final field = TextField(
      controller: controller,
      readOnly: readOnly,
      autofocus: autofocus,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.input.copyWith(
        color: textColor,
        height: 1.1,
      ),
      decoration: InputDecoration(
        hintText: hintWidget == null ? placeholder : null,
        hintStyle: hintStyle,
        prefixIcon: buildSearchIcon(),
        // prefixIconConstraints: const BoxConstraints(
        //   minWidth: 44,
        //   minHeight: 44,
        // ),
        suffixIcon: suffixIcon ?? buildFilterIcon(),
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
      ),
    );

    return SizedBox(
      height: height,
      child: hintWidget == null
          ? field
          : Stack(
              fit: StackFit.expand,
              children: [
                field,
                PositionedDirectional(
                  start: 52,
                  end: (suffixIcon != null || showFilter) ? 58 : AppSpacing.lg,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: controller == null
                          ? DefaultTextStyle(
                              style: hintStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              child: hintWidget!,
                            )
                          : ValueListenableBuilder<TextEditingValue>(
                              valueListenable: controller!,
                              builder: (context, value, _) {
                                if (value.text.isNotEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return DefaultTextStyle(
                                  style: hintStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  child: hintWidget!,
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
