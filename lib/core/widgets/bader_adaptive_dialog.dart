import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../responsive/app_responsive.dart';
import '../theme/app_radius.dart';
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

abstract final class BaderAdaptiveDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<BaderAdaptiveDialogAction<T>> actions,
    bool barrierDismissible = true,
    double? maxWidth,
  }) {
    return showAdaptiveDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        // Rich selectors such as the Scanner branch picker need more room than
        // CupertinoAlertDialog's fixed compact width. When maxWidth is passed,
        // use the same roomy Bader surface on both platforms.
        if (maxWidth != null) {
          final width = dialogContext.responsive.dialogWidth(
            maxWidth: maxWidth,
            fraction: .96,
          );
          final dark = Theme.of(dialogContext).brightness == Brightness.dark;
          final surface = dark
              ? Theme.of(dialogContext).colorScheme.surface
              : Colors.white;

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xxl,
            ),
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: width,
                maxWidth: width,
                minHeight: MediaQuery.sizeOf(dialogContext).height * .34,
                maxHeight: MediaQuery.sizeOf(dialogContext).height * .72,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Flexible(child: content),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: AppSpacing.sm,
                        children: actions
                            .map(
                              (action) => TextButton(
                                onPressed: () => Navigator.of(dialogContext)
                                    .pop(action.result),
                                style: action.isDestructive
                                    ? TextButton.styleFrom(
                                        foregroundColor: Theme.of(dialogContext)
                                            .colorScheme
                                            .error,
                                      )
                                    : null,
                                child: Text(
                                  action.label,
                                  style: action.isDefault
                                      ? const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        )
                                      : null,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (PlatformInfo.isIOS) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Material(color: Colors.transparent, child: content),
            ),
            actions: actions
                .map(
                  (action) => CupertinoDialogAction(
                    isDefaultAction: action.isDefault,
                    isDestructiveAction: action.isDestructive,
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(action.result),
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
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(action.result),
                  style: action.isDestructive
                      ? TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(dialogContext).colorScheme.error,
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
