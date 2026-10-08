import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/partner_manager_repository.dart';

enum PartnerOffersState { loading, loaded, permissionDenied, error }

class PartnerOffersController extends GetxController {
  PartnerOffersController(this.repository);

  final PartnerManagerRepository repository;
  final searchController = TextEditingController();
  final offers = <OfferDetails>[].obs;
  final state = PartnerOffersState.loading.obs;
  final isLoadingMore = false.obs;
  final searchErrorKey = RxnString();
  final query = ''.obs;

  PaginationState? pagination;

  static const int _pageLimit = 20;
  static const int _maxSearchLength = 200;

  @override
  void onInit() {
    super.onInit();
    load(reset: true);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> load({required bool reset}) async {
    if (reset) {
      state.value = PartnerOffersState.loading;
    } else if (isLoadingMore.value || pagination?.hasMore != true) {
      return;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final result = await repository.getPartnerOffers(
        query: ListQuery(
          cursor: reset ? null : pagination?.nextCursor,
          limit: _pageLimit,
          q: query.value.isEmpty ? null : query.value,
        ),
      );
      if (reset) {
        offers.assignAll(result.items);
      } else {
        offers.addAll(result.items);
      }
      pagination = result.pagination;
      state.value = PartnerOffersState.loaded;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? PartnerOffersState.permissionDenied
          : PartnerOffersState.error;
    } catch (_) {
      state.value = PartnerOffersState.error;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refresh() => load(reset: true);

  Future<void> submitSearch(String value) async {
    final normalized = value.trim();
    if (normalized.length > _maxSearchLength) {
      searchErrorKey.value = 'offers_search_too_long';
      return;
    }
    searchErrorKey.value = null;
    query.value = normalized;
    await load(reset: true);
  }

  Future<void> loadMore() => load(reset: false);

  Future<void> openCreate() async {
    final result = await Get.toNamed<dynamic>(AppRoutes.partnerOfferCreate);
    if (result is OfferDetails) await refresh();
  }

  Future<void> openDetails(OfferDetails offer) async {
    final result = await Get.toNamed<dynamic>(
      AppRoutes.partnerOfferDetailsFor(offer.publicId),
      arguments: offer,
    );
    if (result is OfferDetails) await refresh();
  }
}
