import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/widgets/bader_adaptive_snackbar.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/idempotency_key_factory.dart';
import '../../../services/partner_manager_repository.dart';

class PartnerOfferActivateController extends GetxController {
  PartnerOfferActivateController(
    this.repository,
    this.idempotencyKeyFactory, {
    required this.offerPublicId,
    required OfferDetails? initialOffer,
  }) : offer = Rxn<OfferDetails>(initialOffer);

  final PartnerManagerRepository repository;
  final IdempotencyKeyFactory idempotencyKeyFactory;
  final String offerPublicId;
  final Rxn<OfferDetails> offer;
  final isSubmitting = false.obs;
  String? _idempotencyKey;

  Future<void> activate() async {
    if (isSubmitting.value || offerPublicId.isEmpty) return;
    isSubmitting.value = true;
    try {
      final updated = await repository.activatePartnerOffer(
        offerPublicId,
        idempotencyKey: _idempotencyKey ??= idempotencyKeyFactory.create(),
      );
      offer.value = updated;
      _idempotencyKey = null;
      BaderAdaptiveSnackBar.success(
        title: 'offer_activated_title'.tr,
        message: 'offer_activated_message'.tr,
      );
      Get.back(result: updated);
    } on NormalizedApiError catch (error) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: error.statusCode == 403
            ? 'offer_activate_permission_denied'.tr
            : 'offer_activate_error'.tr,
      );
    } catch (_) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'offer_activate_error'.tr,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
