import 'package:flutter/material.dart';

import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Nullable Bader segmented choice used by product forms.
class BaderSegmentedChoice<T> extends StatelessWidget {
  const BaderSegmentedChoice({
    super.key,
    required this.values,
    required this.labels,
    required this.selectedValue,
    required this.onChanged,
    this.color = AppColors.primary,
  }) : assert(values.length == labels.length);

  final List<T> values;
  final List<String> labels;
  final T? selectedValue;
  final ValueChanged<T> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final responsive = context.responsive;
    final effectiveHeight = responsive.veryLargeText
        ? 54.0
        : responsive.largeText
            ? 46.0
            : 40.0;

    return Row(
      children: List.generate(values.length, (index) {
        final value = values[index];
        final selected = value == selectedValue;
        final foreground = selected
            ? Colors.white
            : (dark ? AppColors.darkText : AppColors.textPrimary);

        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == values.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: SizedBox(
              height: effectiveHeight,
              child: Material(
                color: selected ? color : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  side: BorderSide(
                    color: selected
                        ? color
                        : (dark ? AppColors.darkBorder : AppColors.border),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onChanged(value),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        labels[index],
                        maxLines: responsive.veryLargeText ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.small.copyWith(
                          color: foreground,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
