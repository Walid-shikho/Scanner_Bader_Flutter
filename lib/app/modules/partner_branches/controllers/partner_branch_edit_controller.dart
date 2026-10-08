import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/widgets/bader_adaptive_snackbar.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/partner_manager_repository.dart';

enum PartnerBranchEditState {
  loading,
  ready,
  conflict,
  permissionDenied,
  notFound,
  error,
}

class PartnerBranchEditController extends GetxController {
  PartnerBranchEditController(
    this.repository, {
    required this.branchPublicId,
  });

  final PartnerManagerRepository repository;
  final String branchPublicId;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  final state = PartnerBranchEditState.loading.obs;
  final branch = Rxn<PartnerBranchData>();
  final isSubmitting = false.obs;

  String? _etag;
  PartnerBranchData? _baseline;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }

  Future<void> load({bool preserveDraft = false}) async {
    final draft = preserveDraft ? _captureDraft() : null;
    state.value = PartnerBranchEditState.loading;
    try {
      if (branchPublicId.isEmpty) {
        state.value = PartnerBranchEditState.notFound;
        return;
      }
      final snapshot = await repository.getPartnerBranchForEdit(branchPublicId);
      branch.value = snapshot.data;
      _baseline = snapshot.data;
      _etag = snapshot.etag;
      _populate(snapshot.data);
      if (draft != null) _restoreDraft(draft);
      state.value = PartnerBranchEditState.ready;
      if (preserveDraft) {
        BaderAdaptiveSnackBar.success(
          title: 'branch_reloaded_title'.tr,
          message: 'branch_reloaded_retry_message'.tr,
        );
      }
    } on NormalizedApiError catch (error) {
      state.value = switch (error.statusCode) {
        403 => PartnerBranchEditState.permissionDenied,
        404 => PartnerBranchEditState.notFound,
        _ => PartnerBranchEditState.error,
      };
    } catch (_) {
      state.value = PartnerBranchEditState.error;
    }
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    final baseline = _baseline;
    final etag = _etag;
    if (baseline == null || etag == null || etag.isEmpty) {
      state.value = PartnerBranchEditState.error;
      return;
    }

    final latitude = _nullableNumber(latitudeController.text);
    final longitude = _nullableNumber(longitudeController.text);
    if (latitudeController.text.trim().isNotEmpty && latitude == null) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'latitude_invalid'.tr,
      );
      return;
    }
    if (longitudeController.text.trim().isNotEmpty && longitude == null) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'longitude_invalid'.tr,
      );
      return;
    }

    final request = UpdatePartnerBranchRequest(
      name: _patchString(nameController.text, baseline.nameAr),
      address: _patchString(addressController.text, baseline.location?.address),
      phone: _patchString(phoneController.text, baseline.phone),
      latitude: _patchDouble(latitude, baseline.location?.latitude),
      longitude: _patchDouble(longitude, baseline.location?.longitude),
    );

    if (!_hasAnyChange(request)) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'branch_edit_requires_change'.tr,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final updated = await repository.updatePartnerBranch(
        branchPublicId,
        request
      );
      branch.value = updated.data;
      _baseline = updated.data;
      _etag = updated.etag;
      _populate(updated.data);
      BaderAdaptiveSnackBar.success(
        title: 'branch_updated_title'.tr,
        message: 'branch_updated_message'.tr,
      );
      Get.back(result: true);
    } on NormalizedApiError catch (error) {
      if (error.statusCode == 412) {
        state.value = PartnerBranchEditState.conflict;
      } else if (error.statusCode == 403) {
        state.value = PartnerBranchEditState.permissionDenied;
      } else if (error.statusCode == 404) {
        state.value = PartnerBranchEditState.notFound;
      } else {
        BaderAdaptiveSnackBar.error(
          title: 'error'.tr,
          message: 'branch_update_error'.tr,
        );
      }
    } catch (_) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'branch_update_error'.tr,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> reloadForRetry() => load(preserveDraft: true);

  String? validateRequired(String? value, String fieldKey, int maxLength) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'field_required'.trParams({'field': fieldKey.tr});
    if (text.length > maxLength) {
      return 'field_too_long'.trParams({
        'field': fieldKey.tr,
        'max': maxLength.toString(),
      });
    }
    return null;
  }

  String? validateOptional(String? value, String fieldKey, int maxLength) {
    final text = value?.trim() ?? '';
    if (text.length <= maxLength) return null;
    return 'field_too_long'.trParams({
      'field': fieldKey.tr,
      'max': maxLength.toString(),
    });
  }

  void _populate(PartnerBranchData value) {
    nameController.text = value.nameAr;
    addressController.text = value.location?.address ?? '';
    phoneController.text = value.phone ?? '';
    latitudeController.text = value.location?.latitude?.toString() ?? '';
    longitudeController.text = value.location?.longitude?.toString() ?? '';
  }

  Map<String, String> _captureDraft() => <String, String>{
        'name': nameController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'latitude': latitudeController.text,
        'longitude': longitudeController.text,
      };

  void _restoreDraft(Map<String, String> draft) {
    nameController.text = draft['name'] ?? nameController.text;
    addressController.text = draft['address'] ?? addressController.text;
    phoneController.text = draft['phone'] ?? phoneController.text;
    latitudeController.text = draft['latitude'] ?? latitudeController.text;
    longitudeController.text = draft['longitude'] ?? longitudeController.text;
  }

  ContractPatchField<String> _patchString(String raw, String? original) {
    final value = raw.trim();
    final old = original?.trim() ?? '';
    if (value == old) return const ContractPatchField<String>.absent();
    return ContractPatchField<String>.present(value.isEmpty ? null : value);
  }

  ContractPatchField<double> _patchDouble(double? value, double? original) {
    if (value == original) return const ContractPatchField<double>.absent();
    return ContractPatchField<double>.present(value);
  }

  bool _hasAnyChange(UpdatePartnerBranchRequest request) {
    return request.name.isPresent ||
        request.address.isPresent ||
        request.phone.isPresent ||
        request.latitude.isPresent ||
        request.longitude.isPresent;
  }

  double? _nullableNumber(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : double.tryParse(trimmed);
  }
}
