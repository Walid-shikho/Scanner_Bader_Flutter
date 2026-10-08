import 'package:flutter/material.dart';

/// Central semantic typography for Bader.
///
/// The size constants are intentionally limited to a compact type scale so
/// custom widgets can preserve color/weight/responsive behavior without
/// reintroducing arbitrary numeric font sizes.
abstract final class AppTextStyles {
  static const double displayLargeSize = 32;
  static const double displaySize = 28;
  static const double headlineSize = 24;
  static const double pageTitleSize = 22;
  static const double titleSize = 20;
  static const double sectionTitleSize = 18;
  static const double bodyLargeSize = 16;
  static const double bodySize = 14;
  static const double smallSize = 13;
  static const double labelSize = 12;
  static const double captionSize = 11;
  static const double microSize = 10;

  static const displayLarge = TextStyle(
    fontSize: displayLargeSize,
    fontWeight: FontWeight.w700,
    height: 1.18,
    letterSpacing: -0.6,
  );

  static const display = TextStyle(
    fontSize: displaySize,
    fontWeight: FontWeight.w700,
    height: 1.22,
    letterSpacing: -0.5,
  );

  static const headline = TextStyle(
    fontSize: headlineSize,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const pageTitle = TextStyle(
    fontSize: pageTitleSize,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.25,
  );

  static const title = TextStyle(
    fontSize: titleSize,
    fontWeight: FontWeight.w700,
    height: 1.28,
    letterSpacing: -0.2,
  );

  static const sectionTitle = TextStyle(
    fontSize: sectionTitleSize,
    fontWeight: FontWeight.w700,
    height: 1.32,
    letterSpacing: -0.1,
  );

  static const bodyLarge = TextStyle(
    fontSize: bodyLargeSize,
    fontWeight: FontWeight.w500,
    height: 1.50,
  );

  static const body = TextStyle(
    fontSize: bodySize,
    fontWeight: FontWeight.w500,
    height: 1.55,
  );

  static const bodyMedium = TextStyle(
    fontSize: bodySize,
    fontWeight: FontWeight.w600,
    height: 1.50,
  );

  static const bodyBold = TextStyle(
    fontSize: bodySize,
    fontWeight: FontWeight.w700,
    height: 1.50,
  );

  static const small = TextStyle(
    fontSize: smallSize,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const button = TextStyle(
    fontSize: bodySize,
    fontWeight: FontWeight.w700,
    height: 1.20,
    letterSpacing: 0.1,
  );

  static const navigationLabel = TextStyle(
    fontSize: labelSize,
    fontWeight: FontWeight.w700,
    height: 1.20,
  );

  static const label = TextStyle(
    fontSize: labelSize,
    fontWeight: FontWeight.w700,
    height: 1.30,
  );

  static const caption = TextStyle(
    fontSize: captionSize,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const micro = TextStyle(
    fontSize: microSize,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const input = TextStyle(
    fontSize: bodyLargeSize,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const helper = TextStyle(
    fontSize: labelSize,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const error = TextStyle(
    fontSize: labelSize,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // Backward-compatible semantic alias used by the pre-existing TextTheme.
  static const section = sectionTitle;
}
