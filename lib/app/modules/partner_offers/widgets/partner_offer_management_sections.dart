import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bader_adaptive_tap_surface.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_filter_chip.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../models/scanner_partner_models.dart';

class PartnerOfferStatusChip extends StatelessWidget {
  const PartnerOfferStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final normalized = status.trim().toLowerCase();
    final color = switch (normalized) {
      'active' => AppColors.success,
      'draft' => AppColors.warning,
      'disabled' || 'inactive' || 'suspended' => AppColors.danger,
      _ => AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? .17 : .09),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        _offerStatusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class PartnerOfferCard extends StatelessWidget {
  const PartnerOfferCard({
    super.key,
    required this.offer,
    required this.onTap,
  });

  final OfferDetails offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final englishTitle = offer.titleEn?.trim();
    final arabicTitle = offer.titleAr.trim();
    final title = locale == 'ar'
        ? (arabicTitle.isEmpty ? (englishTitle ?? '—') : arabicTitle)
        : (englishTitle?.isNotEmpty == true
            ? (englishTitle ?? '—')
            : (arabicTitle.isEmpty ? '—' : arabicTitle));
    final englishDescription = offer.descriptionEn?.trim();
    final arabicDescription = offer.descriptionAr?.trim();
    final description = locale == 'ar'
        ? arabicDescription
        : (englishDescription?.isNotEmpty == true
            ? englishDescription
            : arabicDescription);
    final accent = offer.discountType == 'points'
        ? AppColors.secondary
        : AppColors.primary;
    final direction = Directionality.of(context);

    return BaderAdaptiveTapSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BaderFormSurface(
        elevated: true,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 7),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BaderAssetIcon(
                            offer.discountType == 'points'
                                ? 'assets/icons/user-check.png'
                                : 'assets/icons/stack-2.png',
                            size: 22,
                            color: accent,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _offerTypeLabel(offer.discountType),
                                  style: AppTextStyles.small.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          PartnerOfferStatusChip(status: offer.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              _offerPrimaryValue(offer),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.headline.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                height: 1,
                              ),
                            ),
                          ),
                          BaderAssetIcon(
                            direction == TextDirection.rtl
                                ? 'assets/icons/chevron-left.png'
                                : 'assets/icons/chevron-right.png',
                            size: 18,
                            color: dark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                      if (description != null && description.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(
                            color: dark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          if (offer.isExclusive)
                            _MetricChip(label: 'exclusive'.tr),
                          _MetricChip(
                            label: 'offer_usage_summary'.trParams({
                              'value': offer.successfulUsageCount.toString(),
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: ColoredBox(
                  color: accent,
                  child: const SizedBox(width: 7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _offerTypeLabel(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'free' => 'offer_type_free'.tr,
    'percentage' => 'offer_type_percentage'.tr,
    'fixed' => 'offer_type_fixed'.tr,
    'points' => 'offer_type_points'.tr,
    _ => raw.replaceAll('_', ' '),
  };
}

String _offerPrimaryValue(OfferDetails offer) {
  final discountValue = offer.discountValue;
  final pointsCost = offer.pointsCost;
  final currencyCode = offer.currencyCode?.trim();
  return switch (offer.discountType.trim().toLowerCase()) {
    'free' => 'offer_type_free'.tr,
    'percentage' => discountValue == null
        ? 'offer_type_percentage'.tr
        : '${_compactNumber(discountValue)}%',
    'fixed' => discountValue == null
        ? 'offer_type_fixed'.tr
        : '${_compactNumber(discountValue)} ${currencyCode ?? ''}'.trim(),
    'points' => pointsCost == null || pointsCost <= 0
        ? 'offer_type_points'.tr
        : 'offer_points_cost'.trParams({'value': pointsCost.toString()}),
    _ => _offerTypeLabel(offer.discountType),
  };
}

String _offerStatusLabel(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'active' => 'status_active'.tr,
    'draft' => 'status_draft'.tr,
    'disabled' => 'status_disabled'.tr,
    'inactive' => 'status_inactive'.tr,
    'suspended' => 'status_suspended'.tr,
    _ => raw.replaceAll('_', ' '),
  };
}

String _compactNumber(num value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');
}

class PartnerOfferInfoRow extends StatelessWidget {
  const PartnerOfferInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class PartnerOfferTaxonomyMultiSelect extends StatelessWidget {
  const PartnerOfferTaxonomyMultiSelect({
    super.key,
    required this.title,
    required this.items,
    required this.selectedPublicIds,
    required this.onToggle,
    this.hint,
  });

  final String title;
  final List<TaxonomyRef> items;
  final Set<String> selectedPublicIds;
  final void Function(String publicId, bool selected) onToggle;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return BaderFormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (hint case final hintText?) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              hintText,
              style: AppTextStyles.small.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: items.map((item) {
              final label = _localizedTaxonomyLabel(item, locale);
              return BaderFilterChip(
                selected: selectedPublicIds.contains(item.publicId),
                label: label,
                onSelected: (selected) => onToggle(item.publicId, selected),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }

  String _localizedTaxonomyLabel(TaxonomyRef item, String locale) {
    if (locale == 'ar') return item.name.ar;
    final german = item.name.de?.trim();
    final english = item.name.en?.trim();
    if (locale == 'de' && german != null && german.isNotEmpty) return german;
    if (english != null && english.isNotEmpty) return english;
    return item.name.ar.trim().isEmpty ? '—' : item.name.ar;
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: dark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
