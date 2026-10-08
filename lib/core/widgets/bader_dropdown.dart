import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'bader_asset_icon.dart';

/// Product dropdown that keeps Bader's form design consistent across
/// platforms. Native/adaptive presentation is reserved for system-semantic
/// pickers and menus rather than ordinary form taxonomy fields.
class BaderDropdownItem<T> {
  const BaderDropdownItem({
    required this.value,
    required this.label,
    this.enabled = true,
    this.icon,
  });

  final T value;
  final String label;
  final bool enabled;
  final Widget? icon;
}

class BaderDropdownFormField<T> extends StatelessWidget {
  const BaderDropdownFormField({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.decoration,
    this.validator,
    this.isExpanded = true,
    this.textStyle,
    this.dropdownColor,
    this.menuBorderRadius,
    this.iconColor,
    this.contentPadding,
    this.autovalidateMode,
  });

  final T? initialValue;
  final List<BaderDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final InputDecoration? decoration;
  final FormFieldValidator<T>? validator;
  final bool isExpanded;
  final TextStyle? textStyle;
  final Color? dropdownColor;
  final BorderRadius? menuBorderRadius;
  final Color? iconColor;
  final EdgeInsetsGeometry? contentPadding;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final baseDecoration = decoration ?? const InputDecoration();
    final effectiveDecoration = contentPadding == null
        ? baseDecoration
        : baseDecoration.copyWith(contentPadding: contentPadding);

    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      isExpanded: isExpanded,
      dropdownColor: dropdownColor,
      borderRadius:
          menuBorderRadius ?? BorderRadius.circular(AppRadius.dialog),
      style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      icon: RotatedBox(
        quarterTurns: 1,
        child: BaderAssetIcon(
          'assets/icons/chevron-right.png',
          color: iconColor,
          size: 20,
        ),
      ),
      decoration: effectiveDecoration,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null) ...[
                    item.icon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }
}
