import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_fading_header.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../../../models/scanner_partner_models.dart';
import '../../partner/widgets/partner_management_sections.dart';
import '../controllers/partner_profile_controller.dart';

class PartnerProfileView extends GetView<PartnerProfileController> {
  const PartnerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BaderAdaptiveScaffold(
      usePageBackground: true,
      body: BaderPageSafeArea(
        bottom: false,
        child: ResponsiveContent(
          maxWidth: 820,
          padding: EdgeInsets.zero,
          child: Obx(() {
            final state = controller.state.value;
            final partner = controller.partner.value;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                AppFadingHeaderSliver(
                  fadeDistance: responsive.isNarrow ? 96 : 112,
                  child: BaderIntegratedPageHeader(
                    title: 'partner_profile'.tr,
                  ),
                ),
                if (state == PartnerProfileState.loading && partner == null)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  )
                else if (state == PartnerProfileState.permissionDenied)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      title: 'permission_denied'.tr,
                      message: 'partner_profile_permission_denied'.tr,
                    ),
                  )
                else if (state == PartnerProfileState.error || partner == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      title: 'error'.tr,
                      message: 'partner_profile_load_error'.tr,
                      actionLabel: 'retry'.tr,
                      onAction: controller.load,
                    ),
                  )
                else
                  SliverPadding(
                    padding: responsive.pageInsets(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.pageBottom,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _PartnerProfileContent(
                        partner: partner,
                        onRequestChange: controller.openChangeRequest,
                        onOperationalEdit: controller.openOperationalEdit,
                        onBranches: controller.openBranches,
                        onMemberships: controller.openMemberships,
                        onOffers: controller.openOffers,
                        onSettings: controller.openSettings,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _PartnerProfileContent extends StatelessWidget {
  const _PartnerProfileContent({
    required this.partner,
    required this.onRequestChange,
    required this.onOperationalEdit,
    required this.onBranches,
    required this.onMemberships,
    required this.onOffers,
    required this.onSettings,
  });

  final PartnerDetail partner;
  final VoidCallback onRequestChange;
  final VoidCallback onOperationalEdit;
  final VoidCallback onBranches;
  final VoidCallback onMemberships;
  final VoidCallback onOffers;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final description = partner.description?.trim();
    final email = partner.contactEmail?.trim();
    final phone = partner.contactPhone?.trim();
    final address = partner.addressLine?.trim();
    final contactFacts = <Widget>[
      if (email != null && email.isNotEmpty)
        _ContactFact(
          icon: 'assets/icons/user.png',
          label: 'partner_contact_email'.tr,
          value: email,
        ),
      if (phone != null && phone.isNotEmpty)
        _ContactFact(
          icon: 'assets/icons/user-check.png',
          label: 'partner_contact_phone'.tr,
          value: phone,
        ),
      if (address != null && address.isNotEmpty)
        _ContactFact(
          icon: 'assets/icons/map-pin.png',
          label: 'partner_address'.tr,
          value: address,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PartnerProfileHeader(
          partner: partner,
          description: description,
        ),
        if (contactFacts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          AppSectionHeader(title: 'partner_contact_section'.tr),
          const SizedBox(height: AppSpacing.sm),
          _ProfileSurface(
            child: Column(
              children: [
                for (var i = 0; i < contactFacts.length; i++) ...[
                  contactFacts[i],
                  if (i != contactFacts.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1),
                    ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppSectionHeader(title: 'quick_actions'.tr),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 360;
            final extent = context.responsive.largeText ? 182.0 : 162.0;
            final cards = <Widget>[
              PartnerManagementActionTile(
                title: 'partner_branches'.tr,
                subtitle: 'partner_branches_hub_subtitle'.tr,
                icon: 'assets/icons/map-pin.png',
                compact: true,
                onTap: onBranches,
              ),
              PartnerManagementActionTile(
                title: 'partner_offers'.tr,
                subtitle: 'partner_offers_hub_subtitle'.tr,
                icon: 'assets/icons/stack-2.png',
                accent: AppColors.secondary,
                compact: true,
                onTap: onOffers,
              ),
              PartnerManagementActionTile(
                title: 'memberships'.tr,
                subtitle: 'partner_memberships_hub_subtitle'.tr,
                icon: 'assets/icons/user-check.png',
                compact: true,
                onTap: onMemberships,
              ),
              PartnerManagementActionTile(
                title: 'settings'.tr,
                subtitle: 'profile_settings_entry_hint'.tr,
                icon: 'assets/icons/settings.png',
                compact: true,
                onTap: onSettings,
              ),
            ];

            if (!twoColumns) {
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    SizedBox(height: extent, child: cards[i]),
                    if (i != cards.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              );
            }

            final width = (constraints.maxWidth - AppSpacing.md) / 2;
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: width,
                      height: extent,
                      child: card,
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppSectionHeader(title: 'profile_management_actions'.tr),
        const SizedBox(height: AppSpacing.sm),
        AppPrimaryButton(
          label: 'edit_operational_profile'.tr,
          icon: 'assets/icons/user.png',
          onPressed: onOperationalEdit,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppPrimaryButton(
          label: 'request_profile_change'.tr,
          icon: 'assets/icons/shield-lock.png',
          backgroundColor: AppColors.secondary,
          onPressed: onRequestChange,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'protected_profile_change_hint'.tr,
          textAlign: TextAlign.center,
          style: AppTextStyles.small.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

class _PartnerProfileHeader extends StatelessWidget {
  const _PartnerProfileHeader({
    required this.partner,
    required this.description,
  });

  final PartnerDetail partner;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final responsive = context.responsive;
    final foreground = dark ? AppColors.darkText : AppColors.textPrimary;
    final secondary =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final avatarSize = responsive.isNarrow ? 82.0 : 92.0;
    final displayName = partner.displayName.trim().isEmpty
        ? partner.legalName
        : partner.displayName;
    final descriptionText = description;

    return Column(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dark ? AppColors.darkSurface : AppColors.surface,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: dark ? .38 : .24),
            ),
            boxShadow: AppShadows.subtle,
          ),
          child: ClipOval(
            child: ColoredBox(
              color: dark ? AppColors.primarySoftDark : AppColors.primarySoft,
              child: Center(
                child: BaderAssetIcon(
                  'assets/icons/user-check.png',
                  size: avatarSize * .42,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Text(
            displayName,
            maxLines: responsive.largeText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.headline.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
              height: 1.12,
              letterSpacing: -.45,
            ),
          ),
        ),
        if (partner.legalName.trim().isNotEmpty &&
            partner.legalName.trim() != displayName.trim()) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            partner.legalName.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.small.copyWith(color: secondary),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        PartnerStatusChip(status: partner.status),
        if (descriptionText != null && descriptionText.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              descriptionText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: secondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileSurface extends StatelessWidget {
  const _ProfileSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: dark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: dark ? const [] : AppShadows.subtle,
      ),
      child: child,
    );
  }
}

class _ContactFact extends StatelessWidget {
  const _ContactFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: dark ? .16 : .09),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: BaderAssetIcon(icon, size: 19, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.bodyBold,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
