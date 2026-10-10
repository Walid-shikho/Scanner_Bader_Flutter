import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../routes/app_routes.dart';
import '../models/onboarding_model.dart';
import '../services/onboarding_service.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._service, this._storage);

  final OnboardingService _service;
  final LocalStorageService _storage;

  late final PageController pageController;
  final index = 0.obs;
  late final List<OnboardingModel> pages;

  @override
  void onInit() {
    pages = _service.getPages();
    pageController = PageController();
    super.onInit();
  }

  void onPageChanged(int value) => index.value = value;

  Future<void> next() async {
    if (index.value == pages.length - 1) {
      await _complete();
      return;
    }

    await pageController.animateToPage(
      index.value + 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> skip() => _complete();

  Future<void> _complete() async {
    await _storage.setBool(StorageKeys.onboardingSeen, true);
    Get.offAllNamed<void>(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
