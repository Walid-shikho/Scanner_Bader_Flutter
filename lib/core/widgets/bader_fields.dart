import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared Bader text field.
///
/// Form inputs intentionally keep the same Bader visual language on iOS and
/// Android. Platform adaptation is reserved for controls where native behavior
/// materially improves the interaction, rather than for ordinary product
/// fields.
class BaderTextField extends StatelessWidget {
  const BaderTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.showCursor,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.decoration,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final Color? cursorColor;
  final double cursorWidth;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final bool? showCursor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      showCursor: showCursor,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      inputFormatters: inputFormatters,
      decoration: decoration,
    );
  }
}

class BaderTextFormField extends StatelessWidget {
  const BaderTextFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.showCursor,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.decoration,
    this.autovalidateMode,
    this.onTapOutside,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final Color? cursorColor;
  final double cursorWidth;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final bool? showCursor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;
  final AutovalidateMode? autovalidateMode;
  final TapRegionCallback? onTapOutside;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      initialValue: initialValue,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      showCursor: showCursor,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      onSaved: onSaved,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: decoration,
      autovalidateMode: autovalidateMode,
      onTapOutside: onTapOutside,
      autofillHints: autofillHints,
    );
  }
}
