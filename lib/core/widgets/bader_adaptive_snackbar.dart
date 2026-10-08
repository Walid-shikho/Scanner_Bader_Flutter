import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Centralized transient feedback for Bader.
///
/// All feedback is rendered through the GetX overlay so callers never need a
/// [Scaffold] or [ScaffoldMessenger] context. The public API intentionally
/// remains semantic (`error`, `warning`, `success`, `info`) while the visual
/// treatment stays neutral across all message types.
abstract final class BaderAdaptiveSnackBar {
  static void error({required String title, required String message}) {
    _show(title: title, message: message);
  }

  static void warning({required String title, required String message}) {
    _show(title: title, message: message);
  }

  static void success({required String title, required String message}) {
    _show(title: title, message: message);
  }

  static void info({required String title, required String message}) {
    _show(title: title, message: message);
  }

  static void _show({required String title, required String message}) {
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;

    final cleanTitle = title.trim();
    final cleanMessage = message.trim();
    if (cleanTitle.isEmpty && cleanMessage.isEmpty) return;

    // Transient feedback should replace an immediately preceding message,
    // rather than creating a vertical snackbar stack.
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    final media = MediaQuery.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? Colors.white : Colors.black;
    final surface = dark
        ? Colors.black.withValues(alpha: .82)
        : Colors.white.withValues(alpha: .92);
    final border = dark
        ? Colors.white.withValues(alpha: .12)
        : Colors.black.withValues(alpha: .08);
    final horizontalMargin = media.size.width < 360 ? AppSpacing.sm : AppSpacing.md;
    final topMargin = media.padding.top + AppSpacing.sm;
    final maxWidth = (media.size.width - (horizontalMargin * 2))
        .clamp(0.0, 560.0)
        .toDouble();

    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      margin: EdgeInsets.fromLTRB(
        horizontalMargin,
        topMargin,
        horizontalMargin,
        0,
      ),
        padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
      maxWidth: maxWidth,
      borderRadius: AppRadius.md,
      borderWidth: 1,
      borderColor: border,
      backgroundColor: surface,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: dark ? .20 : .10),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 220),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      messageText: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cleanTitle.isNotEmpty)
              Text(
                cleanTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyBold.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            if (cleanTitle.isNotEmpty && cleanMessage.isNotEmpty)
              const SizedBox(height: AppSpacing.xs),
            if (cleanMessage.isNotEmpty)
              Text(
                cleanMessage,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.small.copyWith(
                  color: foreground,
                  height: 1.35,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
