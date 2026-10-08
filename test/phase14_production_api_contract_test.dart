import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/scanner_partner_model_codecs.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/network/final_partner_scanner_api_inventory.dart';
import 'package:scanner_partner/core/network/api_error.dart';

void main() {
  group('Final production contract remains preserved during Offline Demo', () {
    test('final 64-entry inventory is intact', () {
      expect(FinalPartnerScannerApiInventory.partnerCount, 31);
      expect(FinalPartnerScannerApiInventory.scannerCount, 25);
      expect(FinalPartnerScannerApiInventory.sharedCount, 8);
      expect(FinalPartnerScannerApiInventory.endpoints.length, 64);
    });

    test('critical canonical methods and paths remain frozen', () {
      final byId = <String, FinalApiEndpoint>{
        for (final endpoint in FinalPartnerScannerApiInventory.endpoints)
          endpoint.apiId: endpoint,
      };
      expect(byId['api.0191']?.path, '/api/v1/scanner/context');
      expect(byId['api.0196']?.method, 'POST');
      expect(byId['api.0196']?.path, '/api/v1/scanner/qr/verify');
      expect(byId['api.0203']?.idempotencyRequired, isTrue);
      expect(byId['api.0213']?.idempotencyRequired, isFalse);
      expect(byId['api.0217']?.idempotencyRequired, isFalse);
      expect(byId['api.0547']?.path, '/api/v1/scanner/statistics');
    });
  });

  group('strict request serialization', () {
    test('verify QR does not send qr_type', () {
      const request = VerifyQrRequest(
        signedQrToken: 'secret-token',
        scannerChallenge: ScannerChallengeText('secret-challenge'),
        branchPublicId: 'branch-id',
      );
      final json = request.toJson();
      expect(json.containsKey('qr_type'), isFalse);
      expect(json['signed_qr_token'], 'secret-token');
      expect(json['scanner_challenge'], 'secret-challenge');
    });

    test('redemption serializes static PIN only when provided', () {
      const noPin = RedemptionRequest(
        scanPublicId: 'scan',
        offerPublicId: 'offer',
        branchPublicId: 'branch',
      );
      expect(noPin.toJson().containsKey('static_qr_pin'), isFalse);

      const withPin = RedemptionRequest(
        scanPublicId: 'scan',
        offerPublicId: 'offer',
        branchPublicId: 'branch',
        staticQrPin: '123456',
      );
      expect(withPin.toJson()['static_qr_pin'], '123456');
    });

    test('PATCH preserves absent versus explicit null', () {
      const request = UpdatePartnerBranchRequest(
        phone: ContractPatchField<String>.present(null),
      );
      expect(request.toJson().containsKey('name'), isFalse);
      expect(request.toJson().containsKey('phone'), isTrue);
      expect(request.toJson()['phone'], isNull);
    });
  });

  test('normalized error does not leak translated body in diagnostics', () {
    final error = NormalizedApiError.fromResponse(
      statusCode: 429,
      headers: const <String, String>{'X-Request-ID': 'r1', 'Retry-After': '30'},
      decodedBody: const <String, dynamic>{
        'message': <String, dynamic>{'ar': 'خطأ'},
        'errors': <dynamic>[
          <String, dynamic>{
            'code': 'RATE_LIMITED',
            'field': null,
            'message': <String, dynamic>{'ar': 'انتظر'},
          },
        ],
      },
    );
    expect(error.requestId, 'r1');
    expect(error.retryAfter, '30');
    expect(error.toString(), isNot(contains('انتظر')));
  });
}
