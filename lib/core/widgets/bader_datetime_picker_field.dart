import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'bader_fields.dart';

/// Read-only Bader form field backed by the platform date/time pickers.
class BaderDateTimePickerField extends StatelessWidget {
  const BaderDateTimePickerField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BaderTextFormField(
      controller: controller,
      readOnly: true,
      showCursor: false,
      validator: validator,
      onTap: () => _pick(context),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Icon(Icons.calendar_month_rounded, size: 20, color: iconColor),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(controller.text.trim());
    final initial = parsed?.toLocal() ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    controller.text = _format(value);
  }

  String _format(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
