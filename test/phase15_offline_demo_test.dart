import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scanner_partner/app/auth/app_mode.dart';
import 'package:scanner_partner/app/auth/app_mode_store.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/routes/app_pages.dart';
import 'package:scanner_partner/app/routes/app_routes.dart';
import 'package:scanner_partner/app/services/offline_auth_session_gateway.dart';
import 'package:scanner_partner/app/services/offline_repositories.dart';
import 'package:scanner_partner/app/services/offline_taxonomy_catalog.dart';
import 'package:scanner_partner/app/services/partner_offline_extras_repository.dart';
import 'package:scanner_partner/app/services/qr_scanner_adapter.dart';
import 'package:scanner_partner/core/config/app_config.dart';
import 'package:scanner_partner/core/config/app_environment.dart';

void main() {
  group('Phase 15 runtime selection', () {
    test('offlineDemo is the delivered environment and production wiring remains source-only', () {
      expect(AppConfig.environment, AppEnvironment.offlineDemo);
      final mainSource = File('lib/main.dart').readAsStringSync();
      expect(mainSource, contains('_configureOfflineRuntime'));
      expect(mainSource, contains('_configureProductionRuntime'));
      final offlineBody = mainSource
          .split('Future<void> _configureOfflineRuntime() async {')[1]
          .split('/// Production wiring')[0];
      expect(offlineBody, isNot(contains('HttpApiTransport(')));
      expect(offlineBody, isNot(contains('FinalContractApiService(')));
      expect(offlineBody, isNot(contains('ApiScannerPartnerRepository(')));
    });

    test('mode selection and guarded shell are registered', () {
      final names = AppPages.pages.map((page) => page.name).toSet();
      expect(names, contains(AppRoutes.modeSelection));
      expect(names, contains(AppRoutes.login));
      expect(names, contains(AppRoutes.shell));
      final shell = AppPages.pages.singleWhere((page) => page.name == AppRoutes.shell);
      expect(shell.middlewares, isNotEmpty);
    });

    test('offline Partner and Scanner login keep separate local flags', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = SharedPreferencesAppModeStore();
      final auth = OfflineAuthSessionGateway(store);

      await auth.loginOffline(
        mode: AppMode.partner,
        email: 'partner@bader.local',
        password: 'demo',
      );
      expect(await auth.isLoggedIn(AppMode.partner), isTrue);
      expect(await auth.isLoggedIn(AppMode.scanner), isFalse);

      await auth.loginOffline(
        mode: AppMode.scanner,
        email: 'scanner@bader.local',
        password: 'demo',
      );
      expect(await auth.isLoggedIn(AppMode.partner), isTrue);
      expect(await auth.isLoggedIn(AppMode.scanner), isTrue);
      expect(await auth.restoreMode(AppMode.partner), isTrue);
      expect(await store.readActiveMode(), AppMode.partner);
    });
  });

  group('Partner offline state', () {
    late OfflineDemoState state;
    late OfflinePartnerManagerRepository partner;
    late OfflinePartnerExtrasRepository extras;

    setUp(() {
      state = OfflineDemoState();
      partner = OfflinePartnerManagerRepository(state);
      extras = OfflinePartnerExtrasRepository(state);
    });

    test('profile and operational fields mutate locally', () async {
      final before = await partner.getPartnerProfile();
      expect(before.displayName, isNotEmpty);
      await extras.updateOperationalProfile(
        const PartnerOperationalProfileUpdate(
          contactEmail: 'new@bader.local',
          contactPhone: '+963111111111',
          address: 'Offline Street 1',
          description: 'Updated locally',
        ),
      );
      final after = await partner.getPartnerProfile();
      expect(after.contactEmail, 'new@bader.local');
      expect(after.description, 'Updated locally');
    });

    test('branches include active and suspended fixtures and support create/edit', () async {
      final initial = await partner.getPartnerBranches();
      expect(initial.items.any((branch) => branch.status == 'active'), isTrue);
      expect(initial.items.any((branch) => branch.status == 'suspended'), isTrue);

      final created = await partner.createPartnerBranch(
        const CreatePartnerBranchRequest(
          name: 'فرع أوفلاين',
          address: 'دمشق',
          provincePublicId: 'demo-province',
          cityPublicId: 'demo-city',
          phone: '+963000000009',
        ),
        idempotencyKey: 'branch-create-1',
      );
      final edited = await partner.updatePartnerBranch(
        created.publicId,
        const UpdatePartnerBranchRequest(
          name: ContractPatchField<String>.present('فرع أوفلاين معدل'),
        ),
      );
      expect(edited.data.nameAr, 'فرع أوفلاين معدل');
    });

    test('memberships expose all finalized demo roles', () async {
      final memberships = await partner.getPartnerMemberships();
      expect(
        memberships.items.map((item) => item.roleCode).toSet(),
        containsAll(<String>{
          'partner_admin',
          'branch_manager',
          'partner_staff',
          'branch_staff',
          'scanner',
        }),
      );
    });

    test('offers support create, edit, activate and disable locally', () async {
      final branches = await partner.getPartnerBranches();
      final created = await partner.createPartnerOffer(
        CreatePartnerOfferRequest(
          name: const LocalizedMessage(ar: 'عرض محلي', en: 'Local Offer', de: 'Lokales Angebot'),
          description: const LocalizedMessage(ar: 'تجربة', en: 'Demo', de: 'Demo'),
          offerType: PartnerOfferType.percentage,
          value: '15',
          branchPublicIds: <String>[branches.items.first.publicId],
          cardTypePublicIds: <String>[OfflineTaxonomyCatalog.cardTypes.first.publicId],
        ),
        idempotencyKey: 'offer-create-1',
      );
      expect(created.status, 'draft');
      final edited = await partner.updatePartnerOffer(
        created.publicId,
        const UpdatePartnerOfferRequest(
          value: ContractPatchField<String>.present('20'),
        ),
      );
      expect(edited.data.discountValue, 20);
      final activated = await partner.activatePartnerOffer(
        created.publicId,
        idempotencyKey: 'offer-activate-1',
      );
      expect(activated.status, 'active');
      final disabled = await partner.disablePartnerOffer(
        created.publicId,
        const DisablePartnerOfferRequest(reason: 'Offline demo'),
        idempotencyKey: 'offer-disable-1',
      );
      expect(disabled.status, 'disabled');
    });

    test('notifications and preferences mutate locally', () async {
      final notifications = await extras.getNotifications();
      expect(notifications.any((item) => !item.read), isTrue);
      await extras.markAllNotificationsRead();
      expect((await extras.getNotifications()).every((item) => item.read), isTrue);
      final prefs = await extras.updateNotificationPreferences(
        const OfflineNotificationPreferences(inAppEnabled: false, pushEnabled: true),
      );
      expect(prefs.inAppEnabled, isFalse);
      expect(prefs.pushEnabled, isTrue);
    });

    test('offline taxonomies include provinces, cities, areas, partner types and card types', () {
      expect(OfflineTaxonomyCatalog.provinces, isNotEmpty);
      expect(OfflineTaxonomyCatalog.cities, isNotEmpty);
      expect(OfflineTaxonomyCatalog.areas, isNotEmpty);
      expect(OfflineTaxonomyCatalog.partnerTypes, isNotEmpty);
      expect(OfflineTaxonomyCatalog.cardTypes, isNotEmpty);
    });
  });

  group('Scanner offline QR and redemption flow', () {
    late OfflineDemoState state;
    late OfflineScannerRepository scanner;

    setUp(() {
      state = OfflineDemoState();
      scanner = OfflineScannerRepository(state);
    });

    Future<ScanVerificationData> verify(OfflineQrScenario scenario) async {
      final context = await scanner.getScannerContext();
      final branch = context.branch!;
      final challenge = await scanner.createQrChallenge(
        ScannerChallengeRequest(branchPublicId: branch.publicId),
      );
      return scanner.verifyQr(
        VerifyQrRequest(
          signedQrToken: scenario.token,
          scannerChallenge: ScannerChallengeText(challenge.challengeToken),
          branchPublicId: branch.publicId,
        ),
      );
    }

    test('scanner branches expose active choices and branch switching works', () async {
      final branches = await scanner.getScannerBranches();
      expect(branches, isNotEmpty);
      expect(branches.every((branch) => branch.status == 'active'), isTrue);
      await scanner.selectScannerBranch(
        SelectScannerBranchRequest(branchPublicId: branches.last.publicId),
      );
      expect((await scanner.getScannerContext()).branch?.publicId, branches.last.publicId);
    });

    test('all six required QR scenarios are deterministic', () async {
      final dynamicResult = await verify(OfflineQrScenario.validDynamic);
      expect(dynamicResult.scanResult, ScanResultValue.eligible);
      expect(dynamicResult.qrType, ScannerQrType.dynamicQr);
      expect(dynamicResult.pinRequired, isFalse);

      final staticResult = await verify(OfflineQrScenario.validStatic);
      expect(staticResult.scanResult, ScanResultValue.eligible);
      expect(staticResult.qrType, ScannerQrType.staticQr);
      expect(staticResult.pinRequired, isTrue);

      expect((await verify(OfflineQrScenario.expired)).scanResult, ScanResultValue.expired);
      expect((await verify(OfflineQrScenario.replayed)).scanResult, ScanResultValue.replayed);
      expect((await verify(OfflineQrScenario.invalid)).scanResult, ScanResultValue.invalid);

      final noOffers = await verify(OfflineQrScenario.noEligibleOffers);
      expect(noOffers.scanResult, ScanResultValue.eligible);
      expect(await scanner.getEligibleOffers(noOffers.scanPublicId), isEmpty);
    });

    test('free, points, percentage and fixed redemptions append local history', () async {
      final verified = await verify(OfflineQrScenario.validDynamic);
      final context = await scanner.getScannerContext();
      final offers = await scanner.getEligibleOffers(verified.scanPublicId);
      final free = offers.firstWhere((offer) => offer.discountType == 'free');
      final points = offers.firstWhere((offer) => offer.discountType == 'points');
      final percentage = offers.firstWhere((offer) => offer.discountType == 'percentage');
      final fixed = offers.firstWhere((offer) => offer.discountType == 'fixed');
      final before = (await scanner.getRedemptions(query: const ListQuery(limit: 100))).items.length;

      await scanner.executeFreeRedemption(
        RedemptionRequest(scanPublicId: verified.scanPublicId, offerPublicId: free.publicId, branchPublicId: context.branch!.publicId),
        idempotencyKey: 'free-1',
      );
      await scanner.executePointsRedemption(
        RedemptionRequest(scanPublicId: verified.scanPublicId, offerPublicId: points.publicId, branchPublicId: context.branch!.publicId),
        idempotencyKey: 'points-1',
      );
      await scanner.executeDiscountRedemption(
        RedemptionRequest(scanPublicId: verified.scanPublicId, offerPublicId: percentage.publicId, branchPublicId: context.branch!.publicId, invoiceAmount: '100000.00'),
        idempotencyKey: 'percentage-1',
      );
      final fixedReceipt = await scanner.executeDiscountRedemption(
        RedemptionRequest(scanPublicId: verified.scanPublicId, offerPublicId: fixed.publicId, branchPublicId: context.branch!.publicId, invoiceAmount: '100000.00'),
        idempotencyKey: 'fixed-1',
      );
      expect(fixedReceipt.discountAmount, '25000.00');
      final after = (await scanner.getRedemptions(query: const ListQuery(limit: 100))).items.length;
      expect(after, before + 4);
    });

    test('reverse updates history and statistics locally', () async {
      final verified = await verify(OfflineQrScenario.validDynamic);
      final context = await scanner.getScannerContext();
      final offer = (await scanner.getEligibleOffers(verified.scanPublicId))
          .firstWhere((item) => item.discountType == 'percentage');
      final beforeStats = await scanner.getDailyStatistics();
      final receipt = await scanner.executeDiscountRedemption(
        RedemptionRequest(scanPublicId: verified.scanPublicId, offerPublicId: offer.publicId, branchPublicId: context.branch!.publicId, invoiceAmount: '50000.00'),
        idempotencyKey: 'stats-redemption-1',
      );
      final afterRedeem = await scanner.getDailyStatistics();
      expect(afterRedeem.successfulRedemptions, beforeStats.successfulRedemptions + 1);
      await scanner.reverseRedemption(
        receipt.publicId,
        const ReverseRedemptionRequest(reason: 'Offline reversal test'),
        idempotencyKey: 'stats-reverse-1',
      );
      final afterReverse = await scanner.getDailyStatistics();
      expect(afterReverse.successfulRedemptions, beforeStats.successfulRedemptions);
      expect((await scanner.getRedemption(receipt.publicId)).result, 'reversed');
    });

    test('daily, weekly and monthly statistics derive from the same mutable local state', () async {
      expect((await scanner.getStatistics(period: 'daily')).date, '2026-10-06');
      expect((await scanner.getStatistics(period: 'weekly')).date, 'weekly');
      expect((await scanner.getStatistics(period: 'monthly')).date, 'monthly');
    });
  });

  group('Static source regression checks', () {
    test('scanner bottom navigation maps second destination to Settings', () {
      final source = File('lib/core/widgets/bader_bottom_nav.dart').readAsStringSync();
      expect(source, contains("label: 'settings'.tr"));
      expect(source, contains("labelKey: 'settings'"));
    });

    test('Shell has no unsafe default-to-scanner fallback', () {
      final source = File('lib/app/modules/shell/controllers/shell_controller.dart').readAsStringSync();
      expect(source, isNot(contains('?? AppMode.scanner')));
    });
  });
}
