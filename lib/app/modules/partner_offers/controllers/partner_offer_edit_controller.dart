import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/widgets/bader_adaptive_snackbar.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/partner_manager_repository.dart';

enum PartnerOfferEditState {
  loading,
  ready,
  conflict,
  permissionDenied,
  notFound,
  error,
}

class PartnerOfferEditController extends GetxController {
  PartnerOfferEditController(
    this.repository, {
    required this.offerPublicId,
  });

  final PartnerManagerRepository repository;
  final String offerPublicId;

  final formKey = GlobalKey<FormState>();
  final nameArController = TextEditingController();
  final nameEnController = TextEditingController();
  final nameDeController = TextEditingController();
  final descriptionArController = TextEditingController();
  final descriptionEnController = TextEditingController();
  final descriptionDeController = TextEditingController();
  final valueController = TextEditingController();
  final pointsCostController = TextEditingController();
  final startsAtController = TextEditingController();
  final endsAtController = TextEditingController();

  final state = PartnerOfferEditState.loading.obs;
  final offer = Rxn<OfferDetails>();
  final isSubmitting = false.obs;

  String? _etag;
  OfferDetails? _baseline;
  static final RegExp _decimalPattern = RegExp(r'^-?[0-9]+(\.[0-9]{1,4})?$');

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    for (final controller in <TextEditingController>[
      nameArController,
      nameEnController,
      nameDeController,
      descriptionArController,
      descriptionEnController,
      descriptionDeController,
      valueController,
      pointsCostController,
      startsAtController,
      endsAtController,
    ]) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> load({bool preserveDraft = false}) async {
    final draft = preserveDraft ? _captureDraft() : null;
    state.value = PartnerOfferEditState.loading;
    try {
      if (offerPublicId.isEmpty) {
        state.value = PartnerOfferEditState.notFound;
        return;
      }
      final snapshot = await repository.getPartnerOfferForEdit(offerPublicId);
      offer.value = snapshot.data;
      _baseline = snapshot.data;
      _etag = snapshot.etag;
      _populate(snapshot.data);
      if (draft != null) _restoreDraft(draft);
      state.value = PartnerOfferEditState.ready;
      if (preserveDraft) {
        BaderAdaptiveSnackBar.success(
          title: 'offer_reloaded_title'.tr,
          message: 'offer_reloaded_retry_message'.tr,
        );
      }
    } on NormalizedApiError catch (error) {
      state.value = switch (error.statusCode) {
        403 => PartnerOfferEditState.permissionDenied,
        404 => PartnerOfferEditState.notFound,
        _ => PartnerOfferEditState.error,
      };
    } catch (_) {
      state.value = PartnerOfferEditState.error;
    }
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    final baseline = _baseline;
    final etag = _etag;
    if (baseline == null || etag == null || etag.isEmpty) {
      state.value = PartnerOfferEditState.error;
      return;
    }

    final startsAt = _nullableDate(startsAtController.text);
    final endsAt = _nullableDate(endsAtController.text);
    if ((startsAtController.text.trim().isNotEmpty && startsAt == null) ||
        (endsAtController.text.trim().isNotEmpty && endsAt == null)) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'offer_datetime_invalid'.tr,
      );
      return;
    }
    final pointsCost = _nullableInt(pointsCostController.text);
    if (pointsCostController.text.trim().isNotEmpty && pointsCost == null) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'offer_points_cost_invalid'.tr,
      );
      return;
    }

    final descriptionChanged = _localizedChanged(
      currentAr: descriptionArController.text,
      currentEn: descriptionEnController.text,
      currentDe: descriptionDeController.text,
      baselineAr: baseline.descriptionAr ?? '',
      baselineEn: baseline.descriptionEn,
    );
    if (descriptionChanged && descriptionArController.text.trim().isEmpty) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'field_required'.trParams({
          'field': 'offer_description_ar'.tr,
        }),
      );
      return;
    }

    final request = UpdatePartnerOfferRequest(
      name: _localizedPatch(
        currentAr: nameArController.text,
        currentEn: nameEnController.text,
        currentDe: nameDeController.text,
        baselineAr: baseline.titleAr,
        baselineEn: baseline.titleEn,
      ),
      description: _localizedPatch(
        currentAr: descriptionArController.text,
        currentEn: descriptionEnController.text,
        currentDe: descriptionDeController.text,
        baselineAr: baseline.descriptionAr ?? '',
        baselineEn: baseline.descriptionEn,
      ),
      value: _patchString(
        valueController.text,
        baseline.discountValue?.toString(),
      ),
      pointsCost: _patchInt(pointsCost, baseline.pointsCost),
      startsAt: _patchDate(startsAt, baseline.startsAt),
      endsAt: _patchDate(endsAt, baseline.endsAt),
    );

    if (!_hasAnyChange(request)) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'offer_edit_requires_change'.tr,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final updated = await repository.updatePartnerOffer(
        offerPublicId,
        request
      );
      offer.value = updated.data;
      _baseline = updated.data;
      _etag = updated.etag;
      _populate(updated.data);
      BaderAdaptiveSnackBar.success(
        title: 'offer_updated_title'.tr,
        message: 'offer_updated_message'.tr,
      );
      Get.back(result: updated.data);
    } on NormalizedApiError catch (error) {
      if (error.statusCode == 412) {
        state.value = PartnerOfferEditState.conflict;
      } else if (error.statusCode == 403) {
        state.value = PartnerOfferEditState.permissionDenied;
      } else if (error.statusCode == 404) {
        state.value = PartnerOfferEditState.notFound;
      } else {
        BaderAdaptiveSnackBar.error(
          title: 'error'.tr,
          message: 'offer_update_error'.tr,
        );
      }
    } catch (_) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'offer_update_error'.tr,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> reloadForRetry() => load(preserveDraft: true);

  String? validateArabicRequired(String? value, String fieldKey) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'field_required'.trParams({'field': fieldKey.tr});
    if (text.length > 500) {
      return 'field_too_long'.trParams({'field': fieldKey.tr, 'max': '500'});
    }
    return null;
  }

  String? validateOptionalLocalized(String? value, String fieldKey) {
    final text = value?.trim() ?? '';
    if (text.length <= 500) return null;
    return 'field_too_long'.trParams({'field': fieldKey.tr, 'max': '500'});
  }

  String? validateValue(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || _decimalPattern.hasMatch(text)) return null;
    return 'offer_value_invalid'.tr;
  }

  String? validatePointsCost(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || int.tryParse(text) != null) return null;
    return 'offer_points_cost_invalid'.tr;
  }

  String? validateDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || DateTime.tryParse(text) != null) return null;
    return 'offer_datetime_invalid'.tr;
  }

  void _populate(OfferDetails value) {
    nameArController.text = value.titleAr;
    nameEnController.text = value.titleEn ?? '';
    nameDeController.text = '';
    descriptionArController.text = value.descriptionAr ?? '';
    descriptionEnController.text = value.descriptionEn ?? '';
    descriptionDeController.text = '';
    valueController.text = value.discountValue?.toString() ?? '';
    pointsCostController.text = value.pointsCost?.toString() ?? '';
    startsAtController.text = value.startsAt.toUtc().toIso8601String();
    endsAtController.text = value.endsAt.toUtc().toIso8601String();
  }

  Map<String, String> _captureDraft() => <String, String>{
        'nameAr': nameArController.text,
        'nameEn': nameEnController.text,
        'nameDe': nameDeController.text,
        'descriptionAr': descriptionArController.text,
        'descriptionEn': descriptionEnController.text,
        'descriptionDe': descriptionDeController.text,
        'value': valueController.text,
        'pointsCost': pointsCostController.text,
        'startsAt': startsAtController.text,
        'endsAt': endsAtController.text,
      };

  void _restoreDraft(Map<String, String> draft) {
    nameArController.text = draft['nameAr'] ?? nameArController.text;
    nameEnController.text = draft['nameEn'] ?? nameEnController.text;
    nameDeController.text = draft['nameDe'] ?? nameDeController.text;
    descriptionArController.text =
        draft['descriptionAr'] ?? descriptionArController.text;
    descriptionEnController.text =
        draft['descriptionEn'] ?? descriptionEnController.text;
    descriptionDeController.text =
        draft['descriptionDe'] ?? descriptionDeController.text;
    valueController.text = draft['value'] ?? valueController.text;
    pointsCostController.text = draft['pointsCost'] ?? pointsCostController.text;
    startsAtController.text = draft['startsAt'] ?? startsAtController.text;
    endsAtController.text = draft['endsAt'] ?? endsAtController.text;
  }

  bool _localizedChanged({
    required String currentAr,
    required String currentEn,
    required String currentDe,
    required String baselineAr,
    required String? baselineEn,
  }) {
    return currentAr.trim() != baselineAr.trim() ||
        _nullableText(currentEn) != _nullableText(baselineEn ?? '') ||
        _nullableText(currentDe) != null;
  }

  LocalizedMessage? _localizedPatch({
    required String currentAr,
    required String currentEn,
    required String currentDe,
    required String baselineAr,
    required String? baselineEn,
  }) {
    final ar = currentAr.trim();
    final en = _nullableText(currentEn);
    final de = _nullableText(currentDe);
    if (ar == baselineAr.trim() &&
        en == _nullableText(baselineEn ?? '') &&
        de == null) {
      return null;
    }
    return LocalizedMessage(ar: ar, en: en, de: de);
  }

  ContractPatchField<String> _patchString(String current, String? original) {
    final now = current.trim();
    final before = original?.trim() ?? '';
    if (now == before) return const ContractPatchField<String>.absent();
    return ContractPatchField<String>.present(now.isEmpty ? null : now);
  }

  ContractPatchField<int> _patchInt(int? current, int? original) {
    if (current == original) return const ContractPatchField<int>.absent();
    return ContractPatchField<int>.present(current);
  }

  ContractPatchField<DateTime> _patchDate(DateTime? current, DateTime original) {
    if (current != null && current.toUtc() == original.toUtc()) {
      return const ContractPatchField<DateTime>.absent();
    }
    return ContractPatchField<DateTime>.present(current);
  }

  bool _hasAnyChange(UpdatePartnerOfferRequest request) {
    return request.name != null ||
        request.description != null ||
        request.value.isPresent ||
        request.pointsCost.isPresent ||
        request.startsAt.isPresent ||
        request.endsAt.isPresent;
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int? _nullableInt(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : int.tryParse(trimmed);
  }

  DateTime? _nullableDate(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : DateTime.tryParse(trimmed);
  }
}
