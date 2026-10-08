import 'package:flutter/material.dart';

abstract final class AppColors {
  // ===========================================================================
  // BADER BRAND IDENTITY
  // ===========================================================================
  static const primary = Color(0xFF0093AD);
  static const primaryDark = Color(0xFF007387);
  static const primaryDeep = Color(0xFF005867);
  static const primarySoft = Color(0xFFE6F5F8);
  static const primarySoftDark = Color(0xFF0D252C);

  static const secondary = Color(0xFFE6792F);
  static const secondaryDark = Color(0xFFC9611B);
  static const secondarySoft = Color(0xFFFFF2E8);
  static const secondarySoftDark = Color(0xFF2C190D);

  // ===========================================================================
  // NEUTRAL SURFACES (LIGHT MODE)
  // ===========================================================================
  static const background = Color(0xFFF6F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFEFF3F6);
  static const surfaceHighlight = Color(0xFFFBFDFE);

  static const border = Color(0xFFE2E8EC);
  static const borderStrong = Color(0xFFD0DAE0);

  static const textPrimary = Color(0xFF11191E);
  static const textSecondary = Color(0xFF5A6B75);
  static const muted = Color(0xFF8E9FA8);

  // ===========================================================================
  // NEUTRAL SURFACES (DARK MODE)
  // ===========================================================================
  static const darkBackground = Color(0xFF0A1014);
  static const darkSurface = Color(0xFF111A20);
  static const darkSurface2 = Color(0xFF18242C);
  static const darkSurfaceElevated = Color(0xFF202F38);

  static const darkBorder = Color(0xFF1F2E37);
  static const darkBorderStrong = Color(0xFF2A3E4A);

  static const darkText = Color(0xFFF3F6F8);
  static const darkTextSecondary = Color(0xFF94A7B2);
  static const darkMuted = Color(0xFF617580);

  // ===========================================================================
  // SEMANTIC COLORS
  // ===========================================================================
  static const success = Color(0xFF2FA36B);
  static const successSoft = Color(0xFFE7F6EE);
  static const warning = Color(0xFFF3A42B);
  static const warningSoft = Color(0xFFFEF5E7);
  static const danger = Color(0xFFE55353);
  static const dangerSoft = Color(0xFFFDECEC);

  // ===========================================================================
  // LIQUID GLASS TOKENS
  // ===========================================================================
  static const glassLight = Color(0xD9FFFFFF);
  static const glassLightBorder = Color(0x330093AD);
  static const glassLightHighlight = Color(0x99FFFFFF);

  static const glassDark = Color(0xD9111A20);
  static const glassDarkBorder = Color(0x24FFFFFF);
  static const glassDarkHighlight = Color(0x1FFFFFFF);

  static const navGlassLight = Color(0xED0D2A32);
  static const navGlassDark = Color(0xED091B20);
}
