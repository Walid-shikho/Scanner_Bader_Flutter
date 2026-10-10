import 'package:get/get.dart';

import '../bindings/feature_bindings.dart';
import '../auth/app_mode.dart';
import '../middleware/app_mode_middleware.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/partner_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/shell_binding.dart';
import '../bindings/splash_binding.dart';
import '../modules/eligible_offers/views/eligible_offers_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/mode_selection_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/memberships/views/memberships_view.dart';
import '../modules/onboarding/controllers/onboarding_controller.dart';
import '../modules/onboarding/services/onboarding_service.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../../core/storage/local_storage_service.dart';
import '../modules/partner/views/partner_view.dart';
import '../modules/partner_branches/views/partner_branch_create_view.dart';
import '../modules/partner_branches/views/partner_branch_edit_view.dart';
import '../modules/partner_branches/views/partner_branches_view.dart';
import '../modules/partner_offers/views/partner_offer_activate_view.dart';
import '../modules/partner_offers/views/partner_offer_create_view.dart';
import '../modules/partner_offers/views/partner_offer_details_view.dart';
import '../modules/partner_offers/views/partner_offer_disable_view.dart';
import '../modules/partner_offers/views/partner_offer_edit_view.dart';
import '../modules/partner_offers/views/partner_offers_view.dart';
import '../modules/partner_profile/views/partner_profile_change_view.dart';
import '../modules/partner_profile/views/partner_profile_operational_edit_view.dart';
import '../modules/partner_notifications/views/partner_notifications_view.dart';
import '../modules/partner_profile/views/partner_profile_view.dart';
import '../modules/qr_challenge/views/qr_challenge_view.dart';
import '../modules/qr_verification/views/qr_verification_view.dart';
import '../modules/redemptions/views/redemption_confirmation_view.dart';
import '../modules/redemptions/views/redemption_details_view.dart';
import '../modules/redemptions/views/redemption_receipt_view.dart';
import '../modules/redemptions/views/redemption_reverse_view.dart';
import '../modules/redemptions/views/redemptions_view.dart';
import '../modules/scan_result/views/scan_result_view.dart';
import '../modules/scanner_branches/views/scanner_branches_view.dart';
import '../modules/scanner_context/views/scanner_context_view.dart';
import '../modules/scanner_devices/views/scanner_devices_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/shell/views/shell_view.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/statistics/views/statistics_view.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingService>(OnboardingService.new);
        Get.lazyPut<OnboardingController>(
          () => OnboardingController(
            Get.find<OnboardingService>(),
            Get.find<LocalStorageService>(),
          ),
        );
      }),
    ),
    GetPage(name: AppRoutes.modeSelection, page: () => const ModeSelectionView(), binding: ModeSelectionBinding()),
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: LoginBinding()),
    GetPage(
      name: AppRoutes.shell,
      middlewares: [ShellModeMiddleware()],
      page: () => const ShellView(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.partner,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerView(),
      binding: PartnerBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      middlewares: [ShellModeMiddleware()],
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),

    GetPage(
      name: AppRoutes.scannerContext,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const ScannerContextView(),
      binding: ScannerContextBinding(),
    ),
    GetPage(
      name: AppRoutes.scannerBranches,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const ScannerBranchesView(),
      binding: ScannerBranchesBinding(),
    ),
    GetPage(
      name: AppRoutes.scannerDevices,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const ScannerDevicesView(),
      binding: ScannerDevicesBinding(),
    ),
    GetPage(
      name: AppRoutes.qrChallenge,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const QrChallengeView(),
      binding: QrChallengeBinding(),
    ),
    GetPage(
      name: AppRoutes.qrVerification,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const QrVerificationView(),
      binding: QrVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.eligibleOffers,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const EligibleOffersView(),
      binding: EligibleOffersBinding(),
    ),
    GetPage(
      name: AppRoutes.scanResult,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const ScanResultView(),
      binding: ScanResultBinding(),
    ),
    GetPage(
      name: AppRoutes.redemptionConfirm,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const RedemptionConfirmationView(),
      binding: RedemptionConfirmationBinding(),
    ),
    GetPage(
      name: AppRoutes.redemptionReceipt,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const RedemptionReceiptView(),
      binding: RedemptionReceiptBinding(),
    ),
    GetPage(
      name: AppRoutes.redemptionReverse,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const RedemptionReverseView(),
      binding: RedemptionReverseBinding(),
    ),
    GetPage(
      name: AppRoutes.redemptionDetails,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const RedemptionDetailsView(),
      binding: RedemptionDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.redemptions,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const RedemptionsView(),
      binding: RedemptionsBinding(),
    ),
    GetPage(
      name: AppRoutes.statistics,
      middlewares: [AppModeMiddleware(AppMode.scanner)],
      page: () => const StatisticsView(),
      binding: StatisticsBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerProfileChange,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerProfileChangeView(),
      binding: PartnerProfileChangeBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerProfile,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerProfileView(),
      binding: PartnerProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerProfileOperationalEdit,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerProfileOperationalEditView(),
      binding: PartnerProfileOperationalEditBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerNotifications,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerNotificationsView(),
      binding: PartnerNotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerBranchCreate,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerBranchCreateView(),
      binding: PartnerBranchCreateBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerBranchEdit,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerBranchEditView(),
      binding: PartnerBranchEditBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerBranches,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerBranchesView(),
      binding: PartnerBranchesBinding(),
    ),
    GetPage(
      name: AppRoutes.memberships,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const MembershipsView(),
      binding: MembershipsBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerOfferCreate,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerOfferCreateView(),
      binding: PartnerOfferCreateBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerOfferEdit,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerOfferEditView(),
      binding: PartnerOfferEditBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerOfferActivate,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerOfferActivateView(),
      binding: PartnerOfferActivateBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerOfferDisable,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerOfferDisableView(),
      binding: PartnerOfferDisableBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerOfferDetails,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerOfferDetailsView(),
      binding: PartnerOfferDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerOffers,
      middlewares: [AppModeMiddleware(AppMode.partner)],
      page: () => const PartnerOffersView(),
      binding: PartnerOffersBinding(),
    ),
  ];
}
