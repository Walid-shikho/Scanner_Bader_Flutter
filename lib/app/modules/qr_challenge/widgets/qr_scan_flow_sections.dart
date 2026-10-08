import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_tap_surface.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_filter_chip.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/qr_scanner_adapter.dart';

class QrFlowProgress extends StatelessWidget {
  const QrFlowProgress({
    super.key,
    required this.title,
    required this.message,
    this.showScannerFrame = false,
  });

  final String title;
  final String message;
  final bool showScannerFrame;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.responsive.pageInsets(
        top: AppSpacing.xl,
        bottom: AppSpacing.huge,
      ),
      children: [
        if (showScannerFrame) ...[
          const QrScannerViewport(isBusy: true),
          const SizedBox(height: AppSpacing.xl),
        ],
        BaderFormSurface(
          elevated: true,
          child: Column(
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2.4),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QrBranchRequiredContent extends StatelessWidget {
  const QrBranchRequiredContent({
    super.key,
    required this.branches,
    required this.isSelecting,
    required this.onSelect,
  });

  final List<PartnerBranchData> branches;
  final bool isSelecting;
  final ValueChanged<PartnerBranchData> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.responsive.pageInsets(
        top: AppSpacing.md,
        bottom: AppSpacing.huge,
      ),
      children: [
        BaderFormSurface(
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const BaderAssetIcon(
                    'assets/icons/map-pin.png',
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'select_branch_before_scan'.tr,
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'select_branch_before_scan_message'.tr,
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (branches.isEmpty)
          BaderFormSurface(
            child: Text(
              'no_scanner_branches_available'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          )
        else
          ...branches.map(
            (branch) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _BranchChoice(
                branch: branch,
                enabled: !isSelecting,
                onTap: () => onSelect(branch),
              ),
            ),
          ),
      ],
    );
  }
}

class _BranchChoice extends StatelessWidget {
  const _BranchChoice({
    required this.branch,
    required this.enabled,
    required this.onTap,
  });

  final PartnerBranchData branch;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppRadius.card);
    final name = _branchName(context, branch);

    return Opacity(
      opacity: enabled ? 1 : .6,
      child: Material(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: BaderAdaptiveTapSurface(
          onTap: enabled ? onTap : null,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: dark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: dark ? .16 : .08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: const BaderAssetIcon(
                    'assets/icons/map-pin.png',
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyBold,
                      ),
                      if ((branch.location?.address?.trim() ?? '').isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          branch.location?.address?.trim() ?? '—',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const BaderAssetIcon(
                  'assets/icons/chevron-right.png',
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QrReadyToScanContent extends StatelessWidget {
  const QrReadyToScanContent({
    super.key,
    required this.contextData,
    required this.onScan,
    this.demoScenarios,
    this.selectedDemoScenario,
    this.onDemoScenarioSelected,
  });

  final ScannerContextData contextData;
  final VoidCallback onScan;
  final List<OfflineQrScenario>? demoScenarios;
  final OfflineQrScenario? selectedDemoScenario;
  final ValueChanged<OfflineQrScenario>? onDemoScenarioSelected;

  @override
  Widget build(BuildContext context) {
    final branch = contextData.branch;
    final scenarios = demoScenarios ?? const <OfflineQrScenario>[];
    return ListView(
      padding: context.responsive.pageInsets(
        top: AppSpacing.md,
        bottom: AppSpacing.huge,
      ),
      children: [
        if (branch != null) ...[
          _CurrentScanContext(branch: branch),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (scenarios.isNotEmpty) ...[
          BaderFormSurface(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.secondarySoftDark
                : AppColors.secondarySoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const BaderAssetIcon(
                        'assets/icons/qrcode.png',
                        size: 21,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'offline_qr_scenario_title'.tr,
                            style: AppTextStyles.bodyBold.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'offline_demo_visual_label'.tr,
                            style: AppTextStyles.caption.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: scenarios.map((scenario) {
                    return BaderFilterChip(
                      selected: scenario == selectedDemoScenario,
                      label: scenario.translationKey.tr,
                      onSelected: (_) => onDemoScenarioSelected?.call(scenario),
                    );
                  }).toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        const QrScannerViewport(),
        const SizedBox(height: AppSpacing.lg),
        Text(
          (scenarios.isNotEmpty ? 'offline_qr_demo_instruction' : 'scanner_camera_instruction').tr,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: 'start_scan'.tr,
          icon: 'assets/icons/qrcode.png',
          onPressed: onScan,
        ),
      ],
    );
  }
}

class _CurrentScanContext extends StatelessWidget {
  const _CurrentScanContext({required this.branch});

  final PartnerBranchData branch;

  @override
  Widget build(BuildContext context) {
    return BaderFormSurface(
      child: Row(
        children: [
          const BaderAssetIcon(
            'assets/icons/map-pin.png',
            size: 22,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'current_branch'.tr,
                  style: AppTextStyles.label.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _branchName(context, branch),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerViewport extends StatelessWidget {
  const QrScannerViewport({super.key, this.isBusy = false});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final border = dark ? AppColors.darkBorderStrong : AppColors.borderStrong;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: CustomPaint(
                  painter: _ScannerFramePainter(
                    color: AppColors.primary,
                    mutedColor: border,
                  ),
                ),
              ),
            ),
            BaderAssetIcon(
              'assets/icons/qrcode.png',
              size: context.responsive.isNarrow ? 72 : 88,
              color: AppColors.primary.withValues(alpha: isBusy ? .35 : .82),
            ),
            if (isBusy)
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: surface.withValues(alpha: .92),
                  shape: BoxShape.circle,
                  border: Border.all(color: border),
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  const _ScannerFramePainter({required this.color, required this.mutedColor});

  final Color color;
  final Color mutedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()
      ..color = mutedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final corner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(AppRadius.lg)),
      guide,
    );

    final segment = size.shortestSide * .18;
    final maxX = size.width;
    final maxY = size.height;

    canvas.drawLine(const Offset(0, 0), Offset(segment, 0), corner);
    canvas.drawLine(const Offset(0, 0), Offset(0, segment), corner);
    canvas.drawLine(Offset(maxX, 0), Offset(maxX - segment, 0), corner);
    canvas.drawLine(Offset(maxX, 0), Offset(maxX, segment), corner);
    canvas.drawLine(Offset(0, maxY), Offset(segment, maxY), corner);
    canvas.drawLine(Offset(0, maxY), Offset(0, maxY - segment), corner);
    canvas.drawLine(
      Offset(maxX, maxY),
      Offset(maxX - segment, maxY),
      corner,
    );
    canvas.drawLine(
      Offset(maxX, maxY),
      Offset(maxX, maxY - segment),
      corner,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerFramePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.mutedColor != mutedColor;
  }
}

class QrVerificationResultContent extends StatelessWidget {
  const QrVerificationResultContent({
    super.key,
    required this.result,
    required this.offers,
    required this.isOffersLoading,
    required this.offersLoadFailed,
    required this.onRetryOffers,
    required this.onOpenOffers,
    required this.onRescan,
    required this.onFinish,
  });

  final ScanVerificationData result;
  final List<OfferDetails> offers;
  final bool isOffersLoading;
  final bool offersLoadFailed;
  final VoidCallback onRetryOffers;
  final VoidCallback onOpenOffers;
  final VoidCallback onRescan;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final presentation = _ResultPresentation.from(result.scanResult);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: context.responsive.pageInsets(
        top: AppSpacing.md,
        bottom: AppSpacing.huge,
      ),
      children: [
        BaderFormSurface(
          elevated: true,
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark
                      ? presentation.color.withValues(alpha: .16)
                      : presentation.softColor,
                ),
                alignment: Alignment.center,
                child: BaderAssetIcon(
                  presentation.icon,
                  size: 32,
                  color: presentation.color,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                presentation.titleKey.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.w900,
                  color: presentation.color,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                presentation.messageKey.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CardholderSurface(result: result),
        const SizedBox(height: AppSpacing.md),
        _VerificationFacts(result: result),
        if (result.scanResult == ScanResultValue.eligible) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'eligible_offers'.tr,
            style: AppTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (result.eligibleOfferCount <= 0)
            BaderFormSurface(
              child: Text(
                'no_eligible_offers'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            )
          else if (isOffersLoading)
            const BaderFormSurface(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.2),
                ),
              ),
            )
          else if (offersLoadFailed)
            BaderFormSurface(
              child: Column(
                children: [
                  Text(
                    'eligible_offers_load_error'.tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: onRetryOffers,
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            )
          else if (offers.isEmpty)
            BaderFormSurface(
              child: Text(
                'no_eligible_offers'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            )
          else
            ...offers.map(
              (offer) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _EligibleOfferCard(offer: offer),
              ),
            ),
        ],
        if (result.scanResult == ScanResultValue.eligible &&
            offers.isNotEmpty &&
            !isOffersLoading &&
            !offersLoadFailed) ...[
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'choose_eligible_offer'.tr,
            icon: 'assets/icons/file-invoice.png',
            onPressed: onOpenOffers,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: 'scan_another_qr'.tr,
          icon: 'assets/icons/qrcode.png',
          onPressed: onRescan,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: onFinish,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
          child: Text('done'.tr),
        ),
      ],
    );
  }
}

class _CardholderSurface extends StatelessWidget {
  const _CardholderSurface({required this.result});

  final ScanVerificationData result;

  @override
  Widget build(BuildContext context) {
    final photo = result.cardholder?.photo;
    return BaderFormSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: .10),
            ),
            child: photo == null || AppConfig.isOfflineDemo
                ? const Center(
                    child: BaderAssetIcon(
                      'assets/icons/user.png',
                      size: 26,
                      color: AppColors.primary,
                    ),
                  )
                : Image.network(
                    photo.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: BaderAssetIcon(
                        'assets/icons/user.png',
                        size: 26,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'cardholder'.tr,
                  style: AppTextStyles.label.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  result.cardholder?.displayName ?? '—',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (result.card.cardType case final cardType?)
                  Text(
                    _taxonomyLabel(context, cardType),
                    style: AppTextStyles.small,
                  ),
                if (result.card.expiresAt case final expiresAt?) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'card_expires_value'.trParams({
                      'value': _date(expiresAt),
                    }),
                    style: AppTextStyles.small.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationFacts extends StatelessWidget {
  const _VerificationFacts({required this.result});

  final ScanVerificationData result;

  @override
  Widget build(BuildContext context) {
    return BaderFormSurface(
      child: Column(
        children: [
          _FactRow(
            label: 'eligible_offer_count'.tr,
            value: result.eligibleOfferCount.toString(),
          ),
          _FactRow(
            label: 'qr_type'.tr,
            value: result.qrType == ScannerQrType.dynamicQr
                ? 'qr_type_dynamic'.tr
                : 'qr_type_static'.tr,
          ),
          _FactRow(
            label: 'bader_linked'.tr,
            value: result.baderLinked ? 'yes'.tr : 'no'.tr,
          ),
          _FactRow(
            label: 'pin_required'.tr,
            value: result.pinRequired ? 'yes'.tr : 'no'.tr,
          ),
          _FactRow(
            label: 'sensitive_redemption_allowed'.tr,
            value: result.sensitiveRedemptionAllowed ? 'yes'.tr : 'no'.tr,
          ),
          _FactRow(
            label: 'verified_at'.tr,
            value: _dateTime(result.verifiedAt),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : AppSpacing.md,
        top: AppSpacing.xs,
      ),
      margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.small.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EligibleOfferCard extends StatelessWidget {
  const _EligibleOfferCard({required this.offer});

  final OfferDetails offer;

  @override
  Widget build(BuildContext context) {
    final title = _offerTitle(context, offer);
    final description = _offerDescription(context, offer);

    return BaderFormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyBold,
                ),
              ),
              if (offer.isExclusive) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'exclusive'.tr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTextStyles.small.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
          if (offer.pointsCost != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'offer_points_cost'.trParams({
                'value': offer.pointsCost.toString(),
              }),
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ] else if (offer.discountValue != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'offer_discount_value'.trParams({
                'value': offer.discountValue.toString(),
                'currency': offer.currencyCode ?? '',
              }),
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultPresentation {
  const _ResultPresentation({
    required this.titleKey,
    required this.messageKey,
    required this.color,
    required this.softColor,
    required this.icon,
  });

  final String titleKey;
  final String messageKey;
  final Color color;
  final Color softColor;
  final String icon;

  factory _ResultPresentation.from(ScanResultValue result) {
    return switch (result) {
      ScanResultValue.eligible => const _ResultPresentation(
          titleKey: 'scan_result_eligible',
          messageKey: 'scan_result_eligible_message',
          color: AppColors.success,
          softColor: AppColors.successSoft,
          icon: 'assets/icons/check.png',
        ),
      ScanResultValue.ineligible => const _ResultPresentation(
          titleKey: 'scan_result_ineligible',
          messageKey: 'scan_result_ineligible_message',
          color: AppColors.warning,
          softColor: AppColors.warningSoft,
          icon: 'assets/icons/qrcode.png',
        ),
      ScanResultValue.expired => const _ResultPresentation(
          titleKey: 'scan_result_expired',
          messageKey: 'scan_result_expired_message',
          color: AppColors.danger,
          softColor: AppColors.dangerSoft,
          icon: 'assets/icons/qrcode.png',
        ),
      ScanResultValue.replayed => const _ResultPresentation(
          titleKey: 'scan_result_replayed',
          messageKey: 'scan_result_replayed_message',
          color: AppColors.danger,
          softColor: AppColors.dangerSoft,
          icon: 'assets/icons/qrcode.png',
        ),
      ScanResultValue.invalid => const _ResultPresentation(
          titleKey: 'scan_result_invalid',
          messageKey: 'scan_result_invalid_message',
          color: AppColors.danger,
          softColor: AppColors.dangerSoft,
          icon: 'assets/icons/qrcode.png',
        ),
    };
  }
}

String _branchName(BuildContext context, PartnerBranchData branch) {
  final language = Localizations.localeOf(context).languageCode;
  if (language == 'ar') return branch.nameAr;
  return branch.nameEn ?? branch.nameAr;
}

String _taxonomyLabel(BuildContext context, TaxonomyRef taxonomy) {
  final language = Localizations.localeOf(context).languageCode;
  return switch (language) {
    'ar' => taxonomy.name.ar,
    'de' => taxonomy.name.de ?? taxonomy.name.en ?? taxonomy.name.ar,
    _ => taxonomy.name.en ?? taxonomy.name.ar,
  };
}

String _offerTitle(BuildContext context, OfferDetails offer) {
  final language = Localizations.localeOf(context).languageCode;
  if (language == 'ar') return offer.titleAr;
  return offer.titleEn ?? offer.titleAr;
}

String? _offerDescription(BuildContext context, OfferDetails offer) {
  final language = Localizations.localeOf(context).languageCode;
  if (language == 'ar') return offer.descriptionAr ?? offer.descriptionEn;
  return offer.descriptionEn ?? offer.descriptionAr;
}

String _date(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

String _dateTime(DateTime value) {
  final local = value.toLocal();
  return '${_date(local)} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
