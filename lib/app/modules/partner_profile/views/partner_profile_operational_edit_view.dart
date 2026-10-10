import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../../../../core/widgets/bader_fields.dart';
import '../../../../core/widgets/bader_form_surface.dart';
import '../../../../core/widgets/bader_integrated_page_header.dart';
import '../../../../core/widgets/bader_page_safe_area.dart';
import '../controllers/partner_profile_operational_edit_controller.dart';

class PartnerProfileOperationalEditView extends GetView<PartnerProfileOperationalEditController> {
  const PartnerProfileOperationalEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: true,
      resizeToAvoidBottomInset: true,
      body: BaderPageSafeArea(
        child: Column(
          children: [
            BaderIntegratedPageHeader(title: 'edit_operational_profile'.tr),
            Expanded(
              child: Obx(() {
                if (controller.loading.value) return Center(child: CircularProgressIndicator.adaptive());
                return ResponsiveContent(
                  maxWidth: 720,
                  padding: context.responsive.pageInsets(
                    top: AppSpacing.sm,
                    bottom: 0,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: ListView(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.pageBottom,
                      ),
                      children: [
                        BaderFormSurface(
                          child: Column(
                            children: [
                              BaderTextFormField(controller: controller.email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'partner_contact_email'.tr), validator: controller.required),
                              const SizedBox(height: AppSpacing.md),
                              BaderTextFormField(controller: controller.phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'partner_contact_phone'.tr), validator: controller.required),
                              const SizedBox(height: AppSpacing.md),
                              BaderTextFormField(controller: controller.address, decoration: InputDecoration(labelText: 'partner_address'.tr), validator: controller.required),
                              const SizedBox(height: AppSpacing.md),
                              BaderTextFormField(controller: controller.description, minLines: 3, maxLines: 5, decoration: InputDecoration(labelText: 'partner_description'.tr), validator: controller.required),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppPrimaryButton(label: 'save'.tr, isLoading: controller.saving.value, onPressed: controller.saving.value ? null : controller.save),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
