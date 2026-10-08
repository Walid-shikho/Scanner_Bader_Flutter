import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/services/mock_scanner_partner_repository.dart';
import 'package:scanner_partner/app/services/step_up_auth_service.dart';

void main() {
  test('QR verification does not auto-redeem', () async {
    final repository = MockScannerPartnerRepository();
    final before = await repository.getRedemptions();
    final context = await repository.getScannerContext();
    final branch = context.branch!;
    final challenge = await repository.createQrChallenge(
      ScannerChallengeRequest(branchPublicId: branch.publicId),
    );

    final result = await repository.verifyQr(
      VerifyQrRequest(
        signedQrToken: 'mock-signed-qr-token-value',
        scannerChallenge: ScannerChallengeText(challenge.challengeToken),
        branchPublicId: branch.publicId,
      ),
    );
    final after = await repository.getRedemptions();

    expect(result.scanResult, ScanResultValue.eligible);
    expect(after.items.length, before.items.length);
  });

  test('production Step-Up boundary remains blocked without a shared contract',
      () async {
    final service = UnconfiguredStepUpAuthService();

    final result = await service.authorizeRedemptionReverse();

    expect(result.outcome, StepUpAuthOutcome.blockedByMissingContract);
    expect(result.isGranted, isFalse);
  });

  test('mock redemption mutations replay the same idempotent response', () async {
    final repository = MockScannerPartnerRepository();
    final context = await repository.getScannerContext();
    final offers = await repository.getEligibleOffers(
      (await repository.getScanResult(
        '0198a6f5-7b8c-7a12-9abc-1234567890ab',
      ))
          .scanPublicId,
    );
    final freeOffer = offers.firstWhere((offer) => offer.discountType == 'free');
    const key = 'mock-idempotency-key';
    final request = RedemptionRequest(
      scanPublicId: '0198a6f5-7b8c-7a12-9abc-1234567890ab',
      offerPublicId: freeOffer.publicId,
      branchPublicId: context.branch!.publicId,
    );

    final first = await repository.executeFreeRedemption(
      request,
      idempotencyKey: key,
    );
    final replay = await repository.executeFreeRedemption(
      request,
      idempotencyKey: key,
    );

    expect(replay.publicId, first.publicId);
  });
}
