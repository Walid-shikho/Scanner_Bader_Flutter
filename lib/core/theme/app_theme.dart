import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';
import 'bader_page_background_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  /// Applies the locale-selected family not only to the main TextTheme, but
  /// also to component text styles that can otherwise bypass it.
  static ThemeData withLocaleFont(ThemeData base, Locale locale) {
    final family = AppFonts.forLocale(locale);
    TextStyle? font(TextStyle? style) => style?.copyWith(fontFamily: family);

    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: family),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: family),
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: font(base.appBarTheme.titleTextStyle),
        toolbarTextStyle: font(base.appBarTheme.toolbarTextStyle),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        hintStyle: font(base.inputDecorationTheme.hintStyle),
        labelStyle: font(base.inputDecorationTheme.labelStyle),
        helperStyle: font(base.inputDecorationTheme.helperStyle),
        errorStyle: font(base.inputDecorationTheme.errorStyle),
        floatingLabelStyle: font(base.inputDecorationTheme.floatingLabelStyle),
        prefixStyle: font(base.inputDecorationTheme.prefixStyle),
        suffixStyle: font(base.inputDecorationTheme.suffixStyle),
        counterStyle: font(base.inputDecorationTheme.counterStyle),
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: font(base.chipTheme.labelStyle),
        secondaryLabelStyle: font(base.chipTheme.secondaryLabelStyle),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        titleTextStyle: font(base.dialogTheme.titleTextStyle),
        contentTextStyle: font(base.dialogTheme.contentTextStyle),
      ),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final elevated = dark ? AppColors.darkSurface2 : AppColors.surfaceElevated;
    final text = dark ? AppColors.darkText : AppColors.textPrimary;
    final secondaryText =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final strongBorder =
        dark ? AppColors.darkBorderStrong : AppColors.borderStrong;
    final scaffoldBackground =
        dark ? AppColors.darkBackground : AppColors.background;

    Color blendPrimary(double alpha) {
      return Color.alphaBlend(
        AppColors.primary.withValues(alpha: alpha),
        scaffoldBackground,
      );
    }

    final pageBackgroundTheme = BaderPageBackgroundTheme(
      background: scaffoldBackground,
      accentStart: blendPrimary(dark ? .14 : .10),
      accentMiddle: blendPrimary(dark ? .075 : .045),
      accentEnd: scaffoldBackground,
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: elevated,
      error: AppColors.danger,
      onError: Colors.white,
      outline: border,
      outlineVariant: strongBorder,
    );

    final textTheme = const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      headlineLarge: AppTextStyles.display,
      headlineMedium: AppTextStyles.headline,
      headlineSmall: AppTextStyles.pageTitle,
      titleLarge: AppTextStyles.sectionTitle,
      titleMedium: AppTextStyles.bodyBold,
      titleSmall: AppTextStyles.small,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.small,
      labelLarge: AppTextStyles.button,
      labelMedium: AppTextStyles.label,
      labelSmall: AppTextStyles.caption,
    ).apply(bodyColor: text, displayColor: text);

    OutlineInputBorder inputBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      extensions: <ThemeExtension<dynamic>>[
        pageBackgroundTheme,
      ],
      colorScheme: scheme,
      cardColor: surface,
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: text,
        titleTextStyle: AppTextStyles.sectionTitle.copyWith(color: text),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: border, width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: AppTextStyles.small.copyWith(
          color: muted,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: AppTextStyles.small.copyWith(
          color: secondaryText,
          fontWeight: FontWeight.w600,
        ),
        helperStyle: AppTextStyles.helper.copyWith(color: secondaryText),
        errorStyle: AppTextStyles.error.copyWith(color: AppColors.danger),
        border: inputBorder(border, 0.9),
        enabledBorder: inputBorder(border, 0.9),
        focusedBorder: inputBorder(AppColors.primary, 1.4),
        errorBorder: inputBorder(AppColors.danger, 1.2),
        focusedErrorBorder: inputBorder(AppColors.danger, 1.4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(color: border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.bodyBold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: elevated,
        selectedColor: AppColors.primary,
        disabledColor: elevated.withValues(alpha: 0.5),
        side: BorderSide(color: border, width: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        labelStyle: AppTextStyles.label.copyWith(color: text),
        secondaryLabelStyle: AppTextStyles.label.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
        titleTextStyle: AppTextStyles.sectionTitle.copyWith(color: text),
        contentTextStyle: AppTextStyles.body.copyWith(color: secondaryText),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
    );
  }
}
