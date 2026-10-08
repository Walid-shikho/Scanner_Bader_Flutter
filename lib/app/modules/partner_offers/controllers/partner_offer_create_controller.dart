import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/widgets/bader_adaptive_snackbar.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/idempotency_key_factory.dart';
import '../../../services/partner_card_type_taxonomy_repository.dart';
import '../../../services/partner_manager_repository.dart';

enum PartnerOfferCreateState { loading, ready, permissionDenied, error }

class PartnerOfferCreateController extends GetxController {
  PartnerOfferCreateController(
    this.repository,
    this.cardTypeRepository,
    this.idempotencyKeyFactory,
  );

  final PartnerManagerRepository repository;
  final PartnerCardTypeTaxonomyRepository cardTypeRepository;
  final IdempotencyKeyFactory idempotencyKeyFactory;

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

  final state = PartnerOfferCreateState.loading.obs;
  final offerType = Rxn<PartnerOfferType>();
  final branches = <PartnerBranchData>[].obs;
  final cardTypes = <TaxonomyRef>[].obs;
  final selectedBranchPublicIds = <String>{}.obs;
  final selectedCardTypePublicIds = <String>{}.obs;
  final isSubmitting = false.obs;
  String? _idempotencyKey;

  bool get productionCardTaxonomyReady => cardTypeRepository.productionReady;
  String? get productionCardTaxonomyBlocker => cardTypeRepository.productionBlocker;

  static final RegExp _decimalPattern = RegExp(r'^-?[0-9]+(\.[0-9]{1,4})?$');

  @override
  void onInit() {
    super.onInit();
    loadDependencies();
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

  Future<void> loadDependencies() async {
    state.value = PartnerOfferCreateState.loading;
    try {
      branches.assignAll(await _loadAllBranches());
      cardTypes.assignAll(await cardTypeRepository.getCardTypes());
      state.value = PartnerOfferCreateState.ready;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? PartnerOfferCreateState.permissionDenied
          : PartnerOfferCreateState.error;
    } catch (_) {
      state.value = PartnerOfferCreateState.error;
    }
  }

  Future<List<PartnerBranchData>> _loadAllBranches() async {
    final values = <PartnerBranchData>[];
    String? cursor;
    do {
      final page = await repository.getPartnerBranches(
        query: ListQuery(cursor: cursor, limit: 20),
      );
      values.addAll(page.items);
      cursor = page.pagination.hasMore ? page.pagination.nextCursor : null;
    } while (cursor != null);
    return values;
  }

  void setOfferType(PartnerOfferType? value) => offerType.value = value;

  void toggleBranch(String publicId, bool selected) {
    selected
        ? selectedBranchPublicIds.add(publicId)
        : selectedBranchPublicIds.remove(publicId);
  }

  void toggleCardType(String publicId, bool selected) {
    selected
        ? selectedCardTypePublicIds.add(publicId)
        : selectedCardTypePublicIds.remove(publicId);
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    final type = offerType.value;
    if (type == null) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'offer_type_required'.tr,
      );
      return;
    }

    final startsAt = _nullableDate(startsAtController.text);
    final endsAt = _nullableDate(endsAtController.text);
    if (startsAtController.text.trim().isNotEmpty && startsAt == null ||
        endsAtController.text.trim().isNotEmpty && endsAt == null) {
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

    isSubmitting.value = true;
    try {
      final created = await repository.createPartnerOffer(
        CreatePartnerOfferRequest(
          name: LocalizedMessage(
            ar: nameArController.text.trim(),
            en: _nullableText(nameEnController.text),
            de: _nullableText(nameDeController.text),
          ),
          description: LocalizedMessage(
            ar: descriptionArController.text.trim(),
            en: _nullableText(descriptionEnController.text),
            de: _nullableText(descriptionDeController.text),
          ),
          offerType: type,
          value: _nullableText(valueController.text),
          pointsCost: pointsCost,
          startsAt: startsAt,
          endsAt: endsAt,
          branchPublicIds: selectedBranchPublicIds.toList(growable: false),
          cardTypePublicIds: selectedCardTypePublicIds.toList(growable: false),
        ),
        idempotencyKey: _idempotencyKey ??= idempotencyKeyFactory.create(),
      );
      BaderAdaptiveSnackBar.success(
        title: 'offer_created_title'.tr,
        message: 'offer_created_message'.tr,
      );
      _idempotencyKey = null;
      Get.back(result: created);
    } on NormalizedApiError catch (error) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: error.statusCode == 403
            ? 'offer_create_permission_denied'.tr
            : 'offer_create_error'.tr,
      );
    } catch (_) {
      BaderAdaptiveSnackBar.error(
        title: 'error'.tr,
        message: 'offer_create_error'.tr,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

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
