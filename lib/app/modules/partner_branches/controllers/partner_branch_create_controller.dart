import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/widgets/bader_adaptive_snackbar.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/idempotency_key_factory.dart';
import '../../../services/partner_location_taxonomy_source.dart';
import '../../../services/partner_manager_repository.dart';

enum PartnerBranchCreateState { loadingTaxonomy, ready, permissionDenied, error }

class PartnerBranchCreateController extends GetxController {
  PartnerBranchCreateController(
    this.repository,
    this.taxonomySource,
    this.idempotencyKeyFactory,
  );

  final PartnerManagerRepository repository;
  final PartnerLocationTaxonomySource taxonomySource;
  final IdempotencyKeyFactory idempotencyKeyFactory;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  final state = PartnerBranchCreateState.loadingTaxonomy.obs;
  final provinces = <TaxonomyRef>[].obs;
  final cities = <TaxonomyRef>[].obs;
  final selectedProvincePublicId = RxnString();
  final selectedCityPublicId = RxnString();
  final isSubmitting = false.obs;
  String? _idempotencyKey;

  bool get productionTaxonomyReady => taxonomySource.productionReady;
  String? get productionTaxonomyBlocker => taxonomySource.productionBlocker;

  @override
  void onInit() {
    super.onInit();
    loadTaxonomy();
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

  Future<void> loadTaxonomy() async {
    state.value = PartnerBranchCreateState.loadingTaxonomy;
    try {
      provinces.assignAll(await taxonomySource.getProvinces());
      if (provinces.isNotEmpty) {
        await selectProvince(provinces.first.publicId);
      }
      state.value = PartnerBranchCreateState.ready;
    } catch (_) {
      state.value = PartnerBranchCreateState.error;
    }
  }

  Future<void> selectProvince(String? publicId) async {
    selectedProvincePublicId.value = publicId;
    selectedCityPublicId.value = null;
    cities.clear();
    if (publicId == null || publicId.isEmpty) return;
    cities.assignAll(
      await taxonomySource.getCities(provincePublicId: publicId),
    );
    if (cities.isNotEmpty) selectedCityPublicId.value = cities.first.publicId;
  }

  void selectCity(String? publicId) {
    selectedCityPublicId.value = publicId;
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final province = selectedProvincePublicId.value;
    final city = selectedCityPublicId.value;
    if (province == null || city == null) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'branch_taxonomy_required'.tr,
      );
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

    isSubmitting.value = true;
    try {
      await repository.createPartnerBranch(
        CreatePartnerBranchRequest(
          name: nameController.text.trim(),
          address: addressController.text.trim(),
          provincePublicId: province,
          cityPublicId: city,
          latitude: latitude,
          longitude: longitude,
          phone: _nullableText(phoneController.text),
        ),
        idempotencyKey: _idempotencyKey ??= idempotencyKeyFactory.create(),
      );
      _idempotencyKey = null;
      BaderAdaptiveSnackBar.success(
        title: 'branch_created_title'.tr,
        message: 'branch_created_message'.tr,
      );
      Get.back(result: true);
    } on NormalizedApiError catch (error) {
      final message = error.statusCode == 403
          ? 'permission_denied'.tr
          : 'branch_create_error'.tr;
      BaderAdaptiveSnackBar.error(title: 'error'.tr, message: message);
    } catch (_) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'branch_create_error'.tr,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

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

  String? validateProvince(String? value) =>
      value == null || value.isEmpty ? 'branch_province_required'.tr : null;

  String? validateCity(String? value) =>
      value == null || value.isEmpty ? 'branch_city_required'.tr : null;

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _nullableNumber(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : double.tryParse(trimmed);
  }
}
