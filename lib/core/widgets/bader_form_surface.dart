import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Shared solid Bader surface for product forms and creation workflows.
///
/// This intentionally avoids glass/blur effects so Create Post and Create
/// Initiative share the same calm product surface language in both themes.
class BaderFormSurface extends StatelessWidget {
  const BaderFormSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.xl,
    this.elevated = false,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool elevated;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (dark ? AppColors.darkSurface : AppColors.surface),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: dark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: elevated ? AppShadows.subtle : null,
      ),
      child: child,
    );
  }
}
