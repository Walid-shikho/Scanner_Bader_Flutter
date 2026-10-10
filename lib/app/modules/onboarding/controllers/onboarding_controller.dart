import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../routes/app_routes.dart';

class ScannerOnboardingPage {
  const ScannerOnboardingPage({
    required this.titleKey,
    required this.descriptionKey,
    required this.imageAsset,
  });

  final String titleKey;
  final String descriptionKey;
  final String imageAsset;
}

class OnboardingController extends GetxController {
  OnboardingController(this._storage);

  final LocalStorageService _storage;
  late final PageController pageController;
  final index = 0.obs;

  final pages = const <ScannerOnboardingPage>[
    ScannerOnboardingPage(
      titleKey: 'scanner_onboarding_1_title',
      descriptionKey: 'scanner_onboarding_1_description',
      imageAsset: 'assets/images/onboarding/onboarding_1.png',
    ),
    ScannerOnboardingPage(
      titleKey: 'scanner_onboarding_2_title',
      descriptionKey: 'scanner_onboarding_2_description',
      imageAsset: 'assets/images/onboarding/onboarding_2.png',
    ),
    ScannerOnboardingPage(
      titleKey: 'scanner_onboarding_3_title',
      descriptionKey: 'scanner_onboarding_3_description',
      imageAsset: 'assets/images/onboarding/onboarding_3.png',
    ),
  ];

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }

  void onPageChanged(int value) => index.value = value;

  Future<void> next() async {
    if (index.value >= pages.length - 1) {
      await complete();
      return;
    }
    await pageController.animateToPage(
      index.value + 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> skip() => complete();

  Future<void> complete() async {
    await _storage.setBool(StorageKeys.onboardingSeen, true);
    Get.offAllNamed<void>(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
