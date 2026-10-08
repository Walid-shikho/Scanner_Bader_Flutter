import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/partner_manager_repository.dart';

enum MembershipsState { loading, loaded, permissionDenied, error }

class MembershipsController extends GetxController {
  MembershipsController(this.repository);

  final PartnerManagerRepository repository;
  final searchController = TextEditingController();
  final items = <PartnerMembershipData>[].obs;
  final state = MembershipsState.loading.obs;
  final isLoadingMore = false.obs;
  final query = ''.obs;
  final searchErrorKey = RxnString();

  PaginationState? pagination;

  static const int _pageLimit = 20;
  static const int _maxSearchLength = 200;

  @override
  void onInit() {
    super.onInit();
    load(reset: true);
  }

  Future<void> load({required bool reset}) async {
    if (reset) {
      state.value = MembershipsState.loading;
    } else if (isLoadingMore.value || pagination?.hasMore != true) {
      return;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final page = await repository.getPartnerMemberships(
        query: ListQuery(
          cursor: reset ? null : pagination?.nextCursor,
          limit: _pageLimit,
          q: query.value.isEmpty ? null : query.value,
        ),
      );

      if (reset) {
        items.assignAll(page.items);
      } else {
        items.addAll(page.items);
      }
      pagination = page.pagination;
      state.value = MembershipsState.loaded;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? MembershipsState.permissionDenied
          : MembershipsState.error;
    } catch (_) {
      state.value = MembershipsState.error;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refresh() => load(reset: true);

  Future<void> submitSearch(String value) async {
    final normalized = value.trim();
    if (normalized.length > _maxSearchLength) {
      searchErrorKey.value = 'memberships_search_too_long';
      return;
    }

    searchErrorKey.value = null;
    query.value = normalized;
    await load(reset: true);
  }

  Future<void> loadMore() => load(reset: false);

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
