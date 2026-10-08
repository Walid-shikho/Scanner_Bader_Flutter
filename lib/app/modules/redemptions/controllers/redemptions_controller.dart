import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/scanner_repository.dart';

enum RedemptionHistoryState { loading, loaded, permissionDenied, error }

class RedemptionsController extends GetxController {
  RedemptionsController(this.repository);

  final ScannerRepository repository;
  final searchController = TextEditingController();
  final items = <RedemptionReceipt>[].obs;
  final state = RedemptionHistoryState.loading.obs;
  final isLoadingMore = false.obs;
  final query = ''.obs;
  PaginationState? pagination;

  static const int _pageLimit = 20;

  @override
  void onInit() {
    super.onInit();
    load(reset: true);
  }

  Future<void> load({required bool reset}) async {
    if (reset) {
      state.value = RedemptionHistoryState.loading;
    } else if (isLoadingMore.value || pagination?.hasMore != true) {
      return;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final page = await repository.getRedemptions(
        query: ListQuery(
          cursor: reset ? null : pagination?.nextCursor,
          limit: _pageLimit,
          q: query.value.trim().isEmpty ? null : query.value.trim(),
        ),
      );
      if (reset) {
        items.assignAll(page.items);
      } else {
        items.addAll(page.items);
      }
      pagination = page.pagination;
      state.value = RedemptionHistoryState.loaded;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? RedemptionHistoryState.permissionDenied
          : RedemptionHistoryState.error;
    } catch (_) {
      state.value = RedemptionHistoryState.error;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refresh() => load(reset: true);

  Future<void> submitSearch(String value) async {
    query.value = value;
    await load(reset: true);
  }

  Future<void> clearSearch() async {
    searchController.clear();
    query.value = '';
    await load(reset: true);
  }

  Future<void> loadMore() => load(reset: false);

  void openDetails(RedemptionReceipt receipt) {
    Get.toNamed<void>(AppRoutes.redemptionDetailsFor(receipt.publicId));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
