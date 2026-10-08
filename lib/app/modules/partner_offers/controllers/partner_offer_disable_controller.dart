import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/widgets/bader_adaptive_snackbar.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/idempotency_key_factory.dart';
import '../../../services/partner_manager_repository.dart';

class PartnerOfferDisableController extends GetxController {
  PartnerOfferDisableController(
    this.repository,
    this.idempotencyKeyFactory, {
    required this.offerPublicId,
    required OfferDetails? initialOffer,
  }) : offer = Rxn<OfferDetails>(initialOffer);

  final PartnerManagerRepository repository;
  final IdempotencyKeyFactory idempotencyKeyFactory;
  final String offerPublicId;
  final Rxn<OfferDetails> offer;
  final reasonController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;
  String? _idempotencyKey;

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  String? validateReason(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'disable_reason_required'.tr;
    if (text.length > 1000) return 'disable_reason_too_long'.tr;
    return null;
  }

  Future<void> disable() async {
    if (isSubmitting.value || offerPublicId.isEmpty) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSubmitting.value = true;
    try {
      final updated = await repository.disablePartnerOffer(
        offerPublicId,
        DisablePartnerOfferRequest(reason: reasonController.text.trim()),
        idempotencyKey: _idempotencyKey ??= idempotencyKeyFactory.create(),
      );
      offer.value = updated;
      _idempotencyKey = null;
      reasonController.clear();
      BaderAdaptiveSnackBar.success(
        title: 'offer_disabled_title'.tr,
        message: 'offer_disabled_message'.tr,
      );
      Get.back(result: updated);
    } on NormalizedApiError catch (error) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: error.statusCode == 403
            ? 'offer_disable_permission_denied'.tr
            : 'offer_disable_error'.tr,
      );
    } catch (_) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'offer_disable_error'.tr,
      );
    } finally {
      reasonController.clear();
      isSubmitting.value = false;
    }
  }
}
