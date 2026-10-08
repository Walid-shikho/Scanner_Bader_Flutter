import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bader_adaptive_tap_surface.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../services/partner_offline_extras_repository.dart';

class PartnerNotificationCard extends StatelessWidget {
  const PartnerNotificationCard({
    super.key,
    required this.item,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final OfflinePartnerNotification item;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final unread = !item.read;
    final text = dark ? AppColors.darkText : AppColors.textPrimary;
    final secondary =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;

    final surface = unread
        ? (dark ? AppColors.primarySoftDark : AppColors.primarySoft)
        : (dark ? AppColors.darkSurface : AppColors.surface);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: unread
              ? AppColors.primary.withValues(alpha: .35)
              : (dark ? AppColors.darkBorder : AppColors.border),
        ),
        boxShadow: dark ? null : AppShadows.subtle,
      ),
      child: BaderAdaptiveTapSurface(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: unread
                      ? AppColors.primary.withValues(alpha: dark ? .22 : .13)
                      : (dark
                          ? AppColors.darkSurface2
                          : AppColors.surfaceElevated),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: BaderAssetIcon(
                  'assets/icons/bell.png',
                  size: 21,
                  color: unread ? AppColors.primary : secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              color: text,
                              fontWeight:
                                  unread ? FontWeight.w800 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small.copyWith(color: secondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _dateTime(item.createdAt),
                      textDirection: TextDirection.ltr,
                      style: AppTextStyles.caption.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dateTime(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}  '
      '${two(local.hour)}:${two(local.minute)}';
}
