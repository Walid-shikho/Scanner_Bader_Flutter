import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/redemption_flow_models.dart';
import 'package:scanner_partner/app/models/scanner_partner_model_codecs.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/services/mock_scanner_partner_repository.dart';
import 'package:scanner_partner/app/services/step_up_auth_service.dart';

OfferDetails _offer(String type) => OfferDetails(
      publicId: '0198a6f0-7b8c-7a12-9abc-1234567890ab',
      discountType: type,
      titleAr: 'عرض',
      startsAt: DateTime.parse('2026-08-07T10:00:00Z'),
      endsAt: DateTime.parse('2026-08-08T10:00:00Z'),
      status: 'active',
      isExclusive: false,
      successfulUsageCount: 0,
      createdAt: DateTime.parse('2026-08-07T10:00:00Z'),
      updatedAt: DateTime.parse('2026-08-07T10:00:00Z'),
    );

void main() {
  test('free, points, and discount offers map to canonical redemption commands', () {
    expect(redemptionCommandForOffer(_offer('free')), RedemptionCommandKind.free);
    expect(
      redemptionCommandForOffer(_offer('points')),
      RedemptionCommandKind.points,
    );
    expect(
      redemptionCommandForOffer(_offer('percentage')),
      RedemptionCommandKind.discount,
    );
    expect(
      redemptionCommandForOffer(_offer('fixed')),
      RedemptionCommandKind.discount,
    );
  });

  test('redemption request serializes PIN only when supplied', () {
    const withoutPin = RedemptionRequest(
      scanPublicId: '0198a6f0-7b8c-7a12-9abc-1234567890ab',
      offerPublicId: '0198a6f1-7b8c-7a12-9abc-1234567890ab',
      branchPublicId: '0198a6f2-7b8c-7a12-9abc-1234567890ab',
    );
    expect(withoutPin.toJson().containsKey('static_qr_pin'), isFalse);

    const withPin = RedemptionRequest(
      scanPublicId: '0198a6f0-7b8c-7a12-9abc-1234567890ab',
      offerPublicId: '0198a6f1-7b8c-7a12-9abc-1234567890ab',
      branchPublicId: '0198a6f2-7b8c-7a12-9abc-1234567890ab',
      staticQrPin: '123456',
    );
    expect(withPin.toJson()['static_qr_pin'], '123456');
    expect(withPin.toString(), isNot(contains('123456')));
  });

  test('mock redemption history supports cursor pagination and search', () async {
    final repository = MockScannerPartnerRepository();

    final first = await repository.getRedemptions(
      query: const ListQuery(limit: 2),
    );
    expect(first.items.length, 2);
    expect(first.pagination.hasMore, isTrue);
    expect(first.pagination.nextCursor, isNotNull);

    final second = await repository.getRedemptions(
      query: ListQuery(limit: 2, cursor: first.pagination.nextCursor),
    );
    expect(second.items, isNotEmpty);
    expect(second.items.first.publicId, isNot(first.items.first.publicId));

    final filtered = await repository.getRedemptions(
      query: const ListQuery(limit: 20, q: 'failed'),
    );
    expect(filtered.items, isNotEmpty);
    expect(filtered.items.every((item) => item.result == 'failed'), isTrue);
  });

  test('unconfigured Step-Up blocks reverse without inventing auth transport', () async {
    final service = UnconfiguredStepUpAuthService();
    final result = await service.authorizeRedemptionReverse();

    expect(result.outcome, StepUpAuthOutcome.blockedByMissingContract);
    expect(result.isGranted, isFalse);
  });
}
