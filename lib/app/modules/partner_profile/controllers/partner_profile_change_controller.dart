import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/widgets/bader_adaptive_snackbar.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/idempotency_key_factory.dart';
import '../../../services/partner_manager_repository.dart';

enum PartnerProfileChangeState { loading, ready, permissionDenied, error }

class PartnerProfileChangeController extends GetxController {
  PartnerProfileChangeController(
    this.repository,
    this.idempotencyKeyFactory,
    Object? unusedFileRepository,
  );

  final PartnerManagerRepository repository;
  final IdempotencyKeyFactory idempotencyKeyFactory;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final displayNameController = TextEditingController();
  final legalNameController = TextEditingController();
  final businessRegistrationController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final reasonController = TextEditingController();

  final state = PartnerProfileChangeState.loading.obs;
  final isSubmitting = false.obs;
  final partner = Rxn<PartnerDetail>();
  String? _idempotencyKey;

  @override
  void onInit() { super.onInit(); load(); }

  @override
  void onClose() {
    nameController.dispose();
    displayNameController.dispose();
    legalNameController.dispose();
    businessRegistrationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  Future<void> load() async {
    state.value = PartnerProfileChangeState.loading;
    try {
      final profile = await repository.getPartnerProfile();
      partner.value = profile;
      nameController.text = profile.displayName;
      displayNameController.text = profile.displayName;
      legalNameController.text = profile.legalName;
      businessRegistrationController.text = profile.businessRegistration ?? '';
      latitudeController.text = profile.latitude?.toString() ?? '';
      longitudeController.text = profile.longitude?.toString() ?? '';
      reasonController.clear();
      state.value = PartnerProfileChangeState.ready;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? PartnerProfileChangeState.permissionDenied
          : PartnerProfileChangeState.error;
    } catch (_) { state.value = PartnerProfileChangeState.error; }
  }

  Future<void> submit() async {
    if (isSubmitting.value || !(formKey.currentState?.validate() ?? false)) return;
    final current = partner.value;
    if (current == null) return;
    final changes = PartnerProfileChanges(
      name: _patchString(nameController.text, current.displayName),
      displayName: _patchString(displayNameController.text, current.displayName),
      legalName: _patchString(legalNameController.text, current.legalName),
      businessRegistration: _patchString(
        businessRegistrationController.text,
        current.businessRegistration,
      ),
      latitude: _patchDouble(latitudeController.text, current.latitude),
      longitude: _patchDouble(longitudeController.text, current.longitude),
    );
    if (!_hasAnyChange(changes)) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'profile_change_requires_change'.tr,
      );
      return;
    }
    isSubmitting.value = true;
    try {
      await repository.requestPartnerProfileChange(
        RequestPartnerProfileChangeRequest(
          changes: changes,
          reason: reasonController.text.trim(),
        ),
        idempotencyKey: _idempotencyKey ??= idempotencyKeyFactory.create(),
      );
      _idempotencyKey = null;
      BaderAdaptiveSnackBar.success(
        title: 'profile_change_submitted_title'.tr,
        message: 'profile_change_submitted_message'.tr,
      );
      Get.back<void>();
    } on NormalizedApiError catch (error) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: error.statusCode == 403
            ? 'permission_denied'.tr
            : 'profile_change_submit_error'.tr,
      );
    } catch (_) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'profile_change_submit_error'.tr,
      );
    } finally { isSubmitting.value = false; }
  }

  String? validateReason(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'profile_change_reason_required'.tr;
    if (text.length > 1000) return 'field_too_long'.trParams({'field': 'profile_change_reason'.tr, 'max': '1000'});
    return null;
  }

  String? validateLatitude(String? value) => _validateCoordinate(value, -90, 90);
  String? validateLongitude(String? value) => _validateCoordinate(value, -180, 180);

  String? _validateCoordinate(String? value, double min, double max) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < min || parsed > max) return 'invalid_value'.tr;
    return null;
  }

  ContractPatchField<String> _patchString(String raw, String? original) {
    final value = raw.trim();
    if (value == (original?.trim() ?? '')) return const ContractPatchField<String>.absent();
    return ContractPatchField<String>.present(value.isEmpty ? null : value);
  }

  ContractPatchField<double> _patchDouble(String raw, double? original) {
    final text = raw.trim();
    final value = text.isEmpty ? null : double.tryParse(text);
    if (value == original) return const ContractPatchField<double>.absent();
    return ContractPatchField<double>.present(value);
  }

  bool _hasAnyChange(PartnerProfileChanges value) =>
      value.name.isPresent || value.displayName.isPresent || value.legalName.isPresent ||
      value.businessRegistration.isPresent || value.latitude.isPresent || value.longitude.isPresent;
}
