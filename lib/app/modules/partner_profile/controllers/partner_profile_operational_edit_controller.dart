import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/partner_manager_repository.dart';
import '../../../services/partner_offline_extras_repository.dart';

class PartnerProfileOperationalEditController extends GetxController {
  PartnerProfileOperationalEditController(this.partnerRepository, this.extrasRepository);

  final PartnerManagerRepository partnerRepository;
  final PartnerExtrasRepository extrasRepository;
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final description = TextEditingController();
  final loading = true.obs;
  final saving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    final partner = await partnerRepository.getPartnerProfile();
    email.text = partner.contactEmail ?? '';
    phone.text = partner.contactPhone ?? '';
    address.text = partner.addressLine ?? '';
    description.text = partner.description ?? '';
    loading.value = false;
  }

  Future<void> save() async {
    if (saving.value || !(formKey.currentState?.validate() ?? false)) return;
    saving.value = true;
    await extrasRepository.updateOperationalProfile(
      PartnerOperationalProfileUpdate(
        contactEmail: email.text.trim(),
        contactPhone: phone.text.trim(),
        address: address.text.trim(),
        description: description.text.trim(),
      ),
    );
    saving.value = false;
    Get.back(result: true);
  }

  String? required(String? value) => (value?.trim().isEmpty ?? true) ? 'field_required_generic'.tr : null;

  @override
  void onClose() {
    email.dispose();
    phone.dispose();
    address.dispose();
    description.dispose();
    super.onClose();
  }
}
