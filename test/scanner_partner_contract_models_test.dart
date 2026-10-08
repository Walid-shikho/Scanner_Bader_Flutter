import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/scanner_partner_endpoint_models.dart';
import 'package:scanner_partner/app/models/scanner_partner_model_codecs.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';

void main() {
  test('API-0196 request serializes contract fields without logging secrets', () {
    const request = VerifyQrRequest(
      signedQrToken: 'signed-secret',
      scannerChallenge: ScannerChallengeText('challenge-secret'),
      branchPublicId: 'branch-id',
      latitude: 33.5,
      longitude: 36.2,
    );

    expect(request.toJson(), <String, dynamic>{
      'signed_qr_token': 'signed-secret',
      'scanner_challenge': 'challenge-secret',
      'branch_public_id': 'branch-id',
      'latitude': 33.5,
      'longitude': 36.2,
    });
    expect(request.toString(), isNot(contains('signed-secret')));
    expect(request.toString(), isNot(contains('challenge-secret')));
  });

  test('PATCH request preserves absent versus explicit null', () {
    const request = UpdatePartnerBranchRequest(
      name: ContractPatchField<String>.absent(),
      phone: ContractPatchField<String>.present(null),
      latitude: ContractPatchField<double>.present(33.5),
    );

    final json = request.toJson();
    expect(json.containsKey('name'), isFalse);
    expect(json.containsKey('phone'), isTrue);
    expect(json['phone'], isNull);
    expect(json['latitude'], 33.5);
  });

  test('API envelope retains pagination metadata separately from data', () {
    final response = ApiEnvelope<List<PartnerMembershipData>>.fromJson(
      <String, dynamic>{
        'success': true,
        'message': <String, dynamic>{
          'ar': 'تم',
          'en': 'Done',
        },
        'data': <Object?>[
          <String, dynamic>{
            'public_id': 'membership-id',
            'user': <String, dynamic>{
              'public_id': 'user-id',
              'display_name': 'User',
              'avatar': null,
              'verified_badge': false,
            },
            'branch': null,
            'role_code': 'scanner',
            'status': 'active',
            'started_at': null,
            'ended_at': null,
            'created_at': '2026-08-07T15:24:12Z',
            'updated_at': '2026-08-07T15:24:12Z',
          },
        ],
        'meta': <String, dynamic>{
          'request_id': 'request-id',
          'timestamp': '2026-08-07T15:24:12Z',
          'pagination': <String, dynamic>{
            'next_cursor': 'next',
            'previous_cursor': null,
            'has_more': true,
            'limit': 20,
          },
        },
      },
      (value) => List<dynamic>.from(value as List)
          .map(PartnerMembershipDataCodec.fromJson)
          .toList(growable: false),
    );

    expect(response.data.single.branch, isNull);
    expect(response.data.single.startedAt, isNull);
    expect(response.meta.requestId, 'request-id');
    expect(response.meta.pagination?.nextCursor, 'next');
  });

}
