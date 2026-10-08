import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
/// Descriptor for an action in [BaderAdaptiveDialog].
class BaderAdaptiveDialogAction<T> {
  const BaderAdaptiveDialogAction({
    required this.label,
    required this.result,
    this.isDefault = false,
    this.isDestructive = false,
  });

  final String label;
  final T result;
  final bool isDefault;
  final bool isDestructive;
}

/// Adaptive dialog helper for cases where adaptive_platform_ui's native
/// [AdaptiveAlertDialog] is intentionally too limited (for example, dialogs
/// containing multiple custom form fields).
///
/// Simple alerts should continue to use [AdaptiveAlertDialog]. This helper is
/// only for rich/custom content and uses the platform-native Flutter dialog
/// presentation on iOS and Android.
abstract final class BaderAdaptiveDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<BaderAdaptiveDialogAction<T>> actions,
    bool barrierDismissible = true,
  }) {
    return showAdaptiveDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        if (PlatformInfo.isIOS) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Material(
                color: Colors.transparent,
                child: content,
              ),
            ),
            actions: actions
                .map(
                  (action) => CupertinoDialogAction(
                    isDefaultAction: action.isDefault,
                    isDestructiveAction: action.isDestructive,
                    onPressed: () => Navigator.of(dialogContext).pop(action.result),
                    child: Text(action.label),
                  ),
                )
                .toList(growable: false),
          );
        }

        return AlertDialog(
          title: Text(title),
          content: content,
          actions: actions
              .map(
                (action) => TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(action.result),
                  style: action.isDestructive
                      ? TextButton.styleFrom(
                          foregroundColor: Theme.of(dialogContext).colorScheme.error,
                        )
                      : null,
                  child: Text(
                    action.label,
                    style: action.isDefault
                        ? const TextStyle(fontWeight: FontWeight.w800)
                        : null,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}
