import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_tap_surface.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../models/redemption_flow_models.dart';
import '../../../models/scanner_partner_models.dart';

String offerDisplayTitle(OfferDetails offer) {
  final language = Get.locale?.languageCode ?? 'ar';
  final titleEn = offer.titleEn?.trim();
  if (language != 'ar' && (titleEn?.isNotEmpty ?? false)) {
    return titleEn ?? offer.titleAr;
  }
  return offer.titleAr;
}

String branchDisplayName(PartnerBranchData branch) {
  final language = Get.locale?.languageCode ?? 'ar';
  final nameEn = branch.nameEn?.trim();
  if (language != 'ar' && (nameEn?.isNotEmpty ?? false)) {
    return nameEn ?? branch.nameAr;
  }
  return branch.nameAr;
}

String compactDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

class RedemptionOfferCard extends StatelessWidget {
  const RedemptionOfferCard({
    super.key,
    required this.offer,
    required this.commandKind,
    this.onSelect,
  });

  final OfferDetails offer;
  final RedemptionCommandKind commandKind;
  final VoidCallback? onSelect;

  bool get _mappingResolved =>
      commandKind == RedemptionCommandKind.free ||
      commandKind == RedemptionCommandKind.points ||
      commandKind == RedemptionCommandKind.discount;

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveTapSurface(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BaderFormSurface(
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    offerDisplayTitle(offer),
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _OfferTypeChip(offer: offer),
              ],
            ),
            if ((offer.descriptionAr?.isNotEmpty ?? false) ||
                (offer.descriptionEn?.isNotEmpty ?? false)) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                (Get.locale?.languageCode == 'ar'
                        ? offer.descriptionAr
                        : offer.descriptionEn) ??
                    offer.descriptionAr ??
                    '',
                style: AppTextStyles.small.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (offer.pointsCost != null)
                  _ValuePill(
                    label: 'offer_points_cost'.trParams({
                      'value': offer.pointsCost.toString(),
                    }),
                  ),
                if (offer.discountValue != null)
                  _ValuePill(
                    label: 'offer_discount_value'.trParams({
                      'value': offer.discountValue.toString(),
                      'currency': offer.currencyCode ?? '',
                    }),
                  ),
                if (offer.isExclusive)
                  _ValuePill(label: 'exclusive'.tr),
              ],
            ),
            if (!_mappingResolved) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'redemption_mapping_unresolved'.tr,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: _mappingResolved
                  ? 'select_offer'.tr
                  : 'contract_clarification_required'.tr,
              onPressed: _mappingResolved ? onSelect : null,
              hasGlow: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferTypeChip extends StatelessWidget {
  const _OfferTypeChip({required this.offer});

  final OfferDetails offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        'offer_type_${offer.discountType}'.tr,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppTextStyles.caption),
    );
  }
}

class RedemptionContextSummary extends StatelessWidget {
  const RedemptionContextSummary({
    super.key,
    required this.args,
  });

  final RedemptionConfirmationArgs args;

  @override
  Widget build(BuildContext context) {
    return BaderFormSurface(
      elevated: true,
      child: Column(
        children: [
          _SummaryRow(
            icon: 'assets/icons/user-check.png',
            label: 'cardholder'.tr,
            value: args.verification.cardholder?.displayName ?? '—',
          ),
          _SummaryRow(
            icon: 'assets/icons/map-pin.png',
            label: 'current_branch'.tr,
            value: branchDisplayName(args.branch),
          ),
          _SummaryRow(
            icon: 'assets/icons/file-invoice.png',
            label: 'selected_offer'.tr,
            value: offerDisplayTitle(args.offer),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
   _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast=false,
  });

  final String icon;
  bool isLast;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaderAssetIcon(icon, size: 21, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: AppTextStyles.bodyBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RedemptionReceiptSurface extends StatelessWidget {
  const RedemptionReceiptSurface({
    super.key,
    required this.receipt,
    this.offer,
  });

  final RedemptionReceipt receipt;
  final OfferDetails? offer;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final success = receipt.result.trim().toLowerCase() == 'completed' ||
        receipt.result.trim().toLowerCase() == 'success';
    final accent = success ? AppColors.success : AppColors.warning;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final border = dark ? AppColors.darkBorder : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    accent,
                    accent.withValues(alpha: .78),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .17),
                    ),
                    child: BaderAssetIcon(
                      success
                          ? 'assets/icons/check.png'
                          : 'assets/icons/file-invoice.png',
                      size: 29,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    receipt.entryType == 'reversal'
                        ? 'reversal_receipt'.tr
                        : 'redemption_receipt'.tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    compactDateTime(receipt.occurredAt),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small.copyWith(
                      color: Colors.white.withValues(alpha: .82),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (offer != null)
                    _ReceiptFact(
                      label: 'selected_offer'.tr,
                      value: offerDisplayTitle(offer!),
                    ),
                  _ReceiptFact(
                    label: 'result'.tr,
                    value: _redemptionResultLabel(receipt.result),
                  ),
                  _ReceiptFact(
                    label: 'quantity'.tr,
                    value: receipt.quantity.toString(),
                  ),
                  if (receipt.invoiceAmount != null)
                    _ReceiptFact(
                      label: 'invoice_amount'.tr,
                      value: '${receipt.invoiceAmount} ${receipt.currencyCode ?? ''}'.trim(),
                    ),
                  if (receipt.discountAmount != null)
                    _ReceiptFact(
                      label: 'discount_amount'.tr,
                      value: '${receipt.discountAmount} ${receipt.currencyCode ?? ''}'.trim(),
                    ),
                  if (receipt.pointsCostSnapshot != null)
                    _ReceiptFact(
                      label: 'points_spent'.tr,
                      value: receipt.pointsCostSnapshot.toString(),
                    ),
                  if ((receipt.reversalReason?.trim() ?? '').isNotEmpty)
                    _ReceiptFact(
                      label: 'reverse_reason'.tr,
                      value: receipt.reversalReason?.trim() ?? '—',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptFact extends StatelessWidget {
  const _ReceiptFact({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary = dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.small.copyWith(color: secondary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

String _redemptionResultLabel(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'completed' || 'success' => 'redemption_completed'.tr,
    'reversed' || 'reversal' => 'reversal'.tr,
    'failed' => 'redemption_failed_label'.tr,
    _ => 'redemption_result_recorded'.tr,
  };
}

class RedemptionHistoryCard extends StatelessWidget {
  const RedemptionHistoryCard({
    super.key,
    required this.receipt,
    required this.onTap,
  });

  final RedemptionReceipt receipt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSuccess = receipt.result == 'completed';
    return BaderAdaptiveTapSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BaderFormSurface(
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess ? AppColors.successSoft : AppColors.warningSoft,
              ),
              alignment: Alignment.center,
              child: BaderAssetIcon(
                receipt.entryType == 'reversal'
                    ? 'assets/icons/stack-2.png'
                    : 'assets/icons/file-invoice.png',
                size: 22,
                color: isSuccess ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.entryType == 'reversal'
                        ? 'reversal'.tr
                        : 'redemption'.tr,
                    style: AppTextStyles.bodyBold,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    compactDateTime(receipt.occurredAt),
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _receiptValue(receipt),
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const BaderAssetIcon(
              'assets/icons/chevron-right.png',
              size: 18,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  String _receiptValue(RedemptionReceipt value) {
    if (value.pointsCostSnapshot != null) {
      return 'redemption_points_value'.trParams({
        'value': value.pointsCostSnapshot.toString(),
      });
    }
    if (value.discountAmount != null) {
      return 'redemption_discount_value'.trParams({
        'value': value.discountAmount.toString(),
        'currency': value.currencyCode ?? '',
      });
    }
    if (value.invoiceAmount != null) {
      return 'redemption_invoice_value'.trParams({
        'value': value.invoiceAmount.toString(),
        'currency': value.currencyCode ?? '',
      });
    }
    return _redemptionResultLabel(value.result);
  }
}

class DailyStatisticsSurface extends StatelessWidget {
  const DailyStatisticsSurface({
    super.key,
    required this.statistics,
  });

  final PartnerDailyStatisticsData statistics;

  @override
  Widget build(BuildContext context) {
    return BaderFormSurface(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            statistics.date,
            style: AppTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'successful_redemptions'.tr,
                  value: statistics.successfulRedemptions.toString(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Metric(
                  label: 'failed_redemptions'.tr,
                  value: statistics.failedRedemptions.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'total_discount_amount'.tr,
                  value: statistics.totalDiscountAmount.toString(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Metric(
                  label: 'points_spent'.tr,
                  value: statistics.pointsSpent.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: dark ? AppColors.primarySoftDark : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title.copyWith(
              color: dark ? AppColors.darkText : AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: dark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
