import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bader_asset_icon.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../models/scanner_partner_models.dart';
import '../../partner/widgets/partner_management_sections.dart';

class PartnerMembershipCard extends StatelessWidget {
  const PartnerMembershipCard({
    super.key,
    required this.membership,
  });

  final PartnerMembershipData membership;

  String _branchLabel(BuildContext context) {
    final branch = membership.branch;
    if (branch == null) return 'membership_unassigned_branch'.tr;

    final language = Localizations.localeOf(context).languageCode;
    if (language != 'ar' && (branch.nameEn?.trim().isNotEmpty ?? false)) {
      return branch.nameEn!;
    }
    return branch.nameAr;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BaderFormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const BaderAssetIcon(
                'assets/icons/user-check.png',
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership.user.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18
                      ),
                    ),
                    if (membership.user.verifiedBadge) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'verified_member'.tr,
                        style: AppTextStyles.small.copyWith(
                          color: secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              PartnerStatusChip(status: membership.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PartnerInfoRow(
            label: 'membership_role'.tr,
            value: _roleLabel(membership.roleCode),
          ),
          PartnerInfoRow(
            label: 'membership_branch'.tr,
            value: _branchLabel(context),
          ),
        ],
      ),
    );
  }
}


String _roleLabel(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'partner_admin' => 'role_partner_admin'.tr,
    'branch_manager' => 'role_branch_manager'.tr,
    'partner_staff' => 'role_partner_staff'.tr,
    'branch_staff' => 'role_branch_staff'.tr,
    'scanner' => 'role_scanner'.tr,
    _ => raw
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' '),
  };
}
