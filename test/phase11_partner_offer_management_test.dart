import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/services/mock_scanner_partner_repository.dart';
import 'package:scanner_partner/app/services/partner_card_type_taxonomy_repository.dart';
import 'package:scanner_partner/app/services/scanner_partner_repository.dart';
import 'package:scanner_partner/core/network/api_error.dart';

void main() {
  group('Phase 11 partner offer management', () {
    test('create draft is idempotent and preserves contract fields', () async {
      final repository = MockScannerPartnerRepository();
      const request = CreatePartnerOfferRequest(
        name: LocalizedMessage(
          ar: 'عرض جديد',
          en: 'New Offer',
          de: 'Neues Angebot',
        ),
        description: LocalizedMessage(
          ar: 'وصف العرض',
          en: 'Offer description',
          de: 'Angebotsbeschreibung',
        ),
        offerType: PartnerOfferType.free,
        branchPublicIds: <String>[],
        cardTypePublicIds: <String>[],
      );

      final first = await repository.createPartnerOffer(
        request,
        idempotencyKey: 'phase11-create-key',
      );
      final replay = await repository.createPartnerOffer(
        request,
        idempotencyKey: 'phase11-create-key',
      );

      expect(first.publicId, replay.publicId);
      expect(first.discountType, 'free');
      expect(first.titleAr, 'عرض جديد');
    });

    test('draft edit retains ETag and stale If-Match yields 412', () async {
      final repository = MockScannerPartnerRepository();
      final page = await repository.getPartnerOffers();
      final offer = page.items.first;
      final snapshot = await repository.getPartnerOfferForEdit(offer.publicId);

      final updated = await repository.updatePartnerOffer(
        offer.publicId,
        const UpdatePartnerOfferRequest(
          name: LocalizedMessage(ar: 'اسم محدث', en: 'Updated name'),
        ),
      );

      expect(updated.data.titleAr, 'اسم محدث');
      expect(updated.etag, isNot(snapshot.etag));

      try {
        await repository.updatePartnerOffer(
          offer.publicId,
          const UpdatePartnerOfferRequest(
            value: ContractPatchField<String>.present('10'),
          ),
        );
        fail('Expected stale ETag to fail');
      } on NormalizedApiError catch (error) {
        expect(error.statusCode, 412);
        expect(error.errors.first.code, 'FAILED_PRECONDITION');
      }
    });

    test('activate and disable are explicit idempotent mutations', () async {
      final repository = MockScannerPartnerRepository();
      final page = await repository.getPartnerOffers();
      final offer = page.items.first;

      final activated = await repository.activatePartnerOffer(
        offer.publicId,
        idempotencyKey: 'phase11-activate-key',
      );
      final activatedReplay = await repository.activatePartnerOffer(
        offer.publicId,
        idempotencyKey: 'phase11-activate-key',
      );
      expect(activated.status, 'active');
      expect(activatedReplay.status, 'active');

      final disabled = await repository.disablePartnerOffer(
        offer.publicId,
        const DisablePartnerOfferRequest(reason: 'Operational change'),
        idempotencyKey: 'phase11-disable-key',
      );
      expect(disabled.status, 'disabled');
    });

    test('owned offers support contract search and cursor pagination', () async {
      final repository = MockScannerPartnerRepository();
      final searched = await repository.getPartnerOffers(
        query: const ListQuery(q: 'Percentage', limit: 20),
      );
      expect(searched.items, isNotEmpty);

      final firstPage = await repository.getPartnerOffers(
        query: const ListQuery(limit: 1),
      );
      expect(firstPage.items.length, 1);
      expect(firstPage.pagination.hasMore, isTrue);
      final secondPage = await repository.getPartnerOffers(
        query: ListQuery(
          limit: 1,
          cursor: firstPage.pagination.nextCursor,
        ),
      );
      expect(secondPage.items.length, 1);
      expect(secondPage.items.first.publicId,
          isNot(firstPage.items.first.publicId));
    });

    test('card type taxonomy is injected mock and production-blocked', () async {
      final taxonomy = MockPartnerCardTypeTaxonomyRepository();
      expect(taxonomy.productionReady, isFalse);
      expect(
        taxonomy.productionBlocker,
        ScannerPartnerContractGaps.cardTypeTaxonomy,
      );
      expect(await taxonomy.getCardTypes(), isNotEmpty);
    });
  });
}
