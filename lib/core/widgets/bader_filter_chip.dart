import 'package:flutter/material.dart';

import '../responsive/app_responsive.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Shared Bader product filter chip.
///
/// Chips are content UI, so their geometry, colors and feedback stay consistent
/// across platforms instead of becoming native/Liquid controls on iOS.
class BaderFilterChip extends StatelessWidget {
  const BaderFilterChip({
    super.key,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.selectedColor,
    this.backgroundColor,
    this.selectedTextColor,
    this.textColor,
    this.checkmarkColor,
    this.borderColor,
    this.selectedBorderColor,
    this.borderRadius,
    this.selectedFontWeight = FontWeight.w800,
    this.fontWeight = FontWeight.w600,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
  });

  final bool selected;
  final String label;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;
  final Color? backgroundColor;
  final Color? selectedTextColor;
  final Color? textColor;
  final Color? checkmarkColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final BorderRadius? borderRadius;
  final FontWeight selectedFontWeight;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.pill);
    final resolvedText = selected
        ? (selectedTextColor ?? Colors.white)
        : (textColor ?? Theme.of(context).colorScheme.onSurface);
    final resolvedColor = selected
        ? (selectedColor ?? Theme.of(context).colorScheme.primary)
        : (backgroundColor ?? Colors.transparent);
    final resolvedBorder = selected
        ? (selectedBorderColor ??
            selectedColor ??
            Theme.of(context).colorScheme.primary)
        : (borderColor ?? Theme.of(context).dividerColor);

    final maxChipWidth = (context.screenWidth -
            (context.responsive.horizontalPagePadding * 2))
        .clamp(120.0, 520.0)
        .toDouble();

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxChipWidth),
      child: Material(
        color: resolvedColor,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: resolvedBorder,
            width: selected ? 1.1 : .85,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSelected(!selected),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Image.asset(
                      'assets/icons/check.png',
                      width: 15,
                      color: checkmarkColor ?? resolvedText,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: context.responsive.largeText ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        color: resolvedText,
                        fontWeight:
                            selected ? selectedFontWeight : fontWeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
