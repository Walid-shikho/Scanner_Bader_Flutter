import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/services/mock_scanner_partner_repository.dart';
import 'package:scanner_partner/app/services/offline_repositories.dart';
import 'package:scanner_partner/app/services/offline_taxonomy_catalog.dart';
import 'package:scanner_partner/app/services/partner_offline_extras_repository.dart';

void main() {
  group('Phase 15.1 points redemption fixes', () {
    late OfflineDemoState state;
    late OfflineScannerRepository scanner;
    late OfflinePartnerManagerRepository partner;
    late String branchPublicId;

    setUp(() async {
      state = OfflineDemoState();
      scanner = OfflineScannerRepository(state);
      partner = OfflinePartnerManagerRepository(state);
      branchPublicId = (await scanner.getScannerContext()).branch!.publicId;
    });

    Future<OfferDetails> createAndActivatePointsOffer({
      required int pointsCost,
      required String suffix,
    }) async {
      final created = await partner.createPartnerOffer(
        CreatePartnerOfferRequest(
          name: LocalizedMessage(
            ar: 'عرض نقاط $pointsCost',
            en: '$pointsCost Point Offer',
            de: '$pointsCost-Punkte-Angebot',
          ),
          description: const LocalizedMessage(
            ar: 'عرض أوفلاين لاختبار التكلفة الفعلية',
            en: 'Offline selected-cost test offer',
            de: 'Offline-Testangebot für ausgewählte Kosten',
          ),
          offerType: PartnerOfferType.points,
          pointsCost: pointsCost,
          branchPublicIds: <String>[branchPublicId],
          cardTypePublicIds: <String>[
            OfflineTaxonomyCatalog.cardTypes.first.publicId,
          ],
        ),
        idempotencyKey: 'create-points-$suffix',
      );
      return partner.activatePartnerOffer(
        created.publicId,
        idempotencyKey: 'activate-points-$suffix',
      );
    }

    test('existing 300-point offer deducts exactly 300', () async {
      final offers = await partner.getPartnerOffers(
        query: const ListQuery(limit: 100),
      );
      final offer = offers.items.firstWhere(
        (item) => item.discountType == 'points' && item.pointsCost == 300,
      );
      final before = state.engine.offlineWalletPoints;

      final receipt = await scanner.executePointsRedemption(
        RedemptionRequest(
          scanPublicId: 'offline-scan-phase15-1-300',
          offerPublicId: offer.publicId,
          branchPublicId: branchPublicId,
        ),
        idempotencyKey: 'points-300',
      );

      expect(receipt.pointsCostSnapshot, 300);
      expect(state.engine.offlineWalletPoints, before - 300);
    });

    test('newly created 500-point offer deducts exactly 500', () async {
      final offer = await createAndActivatePointsOffer(
        pointsCost: 500,
        suffix: '500',
      );
      final before = state.engine.offlineWalletPoints;

      final receipt = await scanner.executePointsRedemption(
        RedemptionRequest(
          scanPublicId: 'offline-scan-phase15-1-500',
          offerPublicId: offer.publicId,
          branchPublicId: branchPublicId,
        ),
        idempotencyKey: 'points-500',
      );

      expect(receipt.pointsCostSnapshot, 500);
      expect(state.engine.offlineWalletPoints, before - 500);
    });

    test('invalid points cost fails deterministically before mutation', () async {
      final offer = await createAndActivatePointsOffer(
        pointsCost: 0,
        suffix: 'invalid-cost',
      );
      final beforeWallet = state.engine.offlineWalletPoints;
      final beforeHistory = (await scanner.getRedemptions(
        query: const ListQuery(limit: 100),
      ))
          .items
          .length;

      try {
        await scanner.executePointsRedemption(
          RedemptionRequest(
            scanPublicId: 'offline-scan-phase15-1-invalid-cost',
            offerPublicId: offer.publicId,
            branchPublicId: branchPublicId,
          ),
          idempotencyKey: 'points-invalid-cost',
        );
        fail('Expected deterministic Offline invalid-points-cost error.');
      } on OfflineDemoValidationException catch (error) {
        expect(error.code, 'OFFLINE_POINTS_COST_INVALID');
      }

      expect(state.engine.offlineWalletPoints, beforeWallet);
      final afterHistory = (await scanner.getRedemptions(
        query: const ListQuery(limit: 100),
      ))
          .items
          .length;
      expect(afterHistory, beforeHistory);
    });

    test('reversal refunds the exact recorded points snapshot', () async {
      final offer = await createAndActivatePointsOffer(
        pointsCost: 500,
        suffix: 'refund',
      );
      final before = state.engine.offlineWalletPoints;
      final redemption = await scanner.executePointsRedemption(
        RedemptionRequest(
          scanPublicId: 'offline-scan-phase15-1-refund',
          offerPublicId: offer.publicId,
          branchPublicId: branchPublicId,
        ),
        idempotencyKey: 'points-refund-redemption',
      );
      expect(redemption.pointsCostSnapshot, 500);
      expect(state.engine.offlineWalletPoints, before - 500);

      final reversal = await scanner.reverseRedemption(
        redemption.publicId,
        const ReverseRedemptionRequest(reason: 'Phase 15.1 exact refund test'),
        idempotencyKey: 'points-refund-reversal',
      );

      expect(reversal.pointsCostSnapshot, 500);
      expect(state.engine.offlineWalletPoints, before);
    });

    test('insufficient points fails deterministically without success record', () async {
      final offer = await createAndActivatePointsOffer(
        pointsCost: 2000,
        suffix: 'insufficient',
      );
      final beforeWallet = state.engine.offlineWalletPoints;
      final beforeHistory = (await scanner.getRedemptions(
        query: const ListQuery(limit: 100),
      ))
          .items
          .length;

      try {
        await scanner.executePointsRedemption(
          RedemptionRequest(
            scanPublicId: 'offline-scan-phase15-1-insufficient',
            offerPublicId: offer.publicId,
            branchPublicId: branchPublicId,
          ),
          idempotencyKey: 'points-insufficient',
        );
        fail('Expected deterministic Offline insufficient-points error.');
      } on OfflineDemoValidationException catch (error) {
        expect(error.code, 'OFFLINE_INSUFFICIENT_POINTS');
      }

      expect(state.engine.offlineWalletPoints, beforeWallet);
      final afterHistory = (await scanner.getRedemptions(
        query: const ListQuery(limit: 100),
      ))
          .items
          .length;
      expect(afterHistory, beforeHistory);
    });
  });

  group('Phase 15.1 protected Partner profile request fix', () {
    late OfflineDemoState state;
    late OfflinePartnerManagerRepository partner;
    late OfflinePartnerExtrasRepository extras;

    setUp(() {
      state = OfflineDemoState();
      partner = OfflinePartnerManagerRepository(state);
      extras = OfflinePartnerExtrasRepository(state);
    });

    test('protected change remains pending and canonical profile is unchanged', () async {
      final before = await partner.getPartnerProfile();
      final response = await partner.requestPartnerProfileChange(
        const RequestPartnerProfileChangeRequest(
          changes: PartnerProfileChanges(
            displayName: ContractPatchField<String>.present('اسم محمي جديد'),
            legalName: ContractPatchField<String>.present('اسم قانوني جديد'),
            businessRegistration:
                ContractPatchField<String>.present('CR-OFFLINE-151'),
            latitude: ContractPatchField<double>.present(34.1234),
            longitude: ContractPatchField<double>.present(35.5678),
          ),
          reason: 'Phase 15.1 protected change simulation',
        ),
        idempotencyKey: 'profile-change-phase15-1',
      );

      expect(response.publicId, before.publicId);
      final pending = state.engine.pendingPartnerProfileChangeRequests;
      expect(pending, hasLength(1));
      expect(pending.single.status, 'pending');
      expect(pending.single.reason, 'Phase 15.1 protected change simulation');
      expect(pending.single.createdAt, isNotNull);
      expect(pending.single.changes.displayName.value, 'اسم محمي جديد');
      expect(pending.single.changes.legalName.value, 'اسم قانوني جديد');
      expect(
        pending.single.changes.businessRegistration.value,
        'CR-OFFLINE-151',
      );

      final after = await partner.getPartnerProfile();
      expect(after.displayName, before.displayName);
      expect(after.legalName, before.legalName);
      expect(after.businessRegistration, before.businessRegistration);
      expect(after.latitude, before.latitude);
      expect(after.longitude, before.longitude);
    });

    test('operational profile edit remains direct and mutable', () async {
      await extras.updateOperationalProfile(
        const PartnerOperationalProfileUpdate(
          contactEmail: 'phase15.1@bader.local',
          contactPhone: '+963151151151',
          address: 'Phase 15.1 Offline Address',
          description: 'Phase 15.1 direct operational edit',
        ),
      );

      final after = await partner.getPartnerProfile();
      expect(after.contactEmail, 'phase15.1@bader.local');
      expect(after.contactPhone, '+963151151151');
      expect(after.addressLine, 'Phase 15.1 Offline Address');
      expect(after.description, 'Phase 15.1 direct operational edit');
    });
  });
}
