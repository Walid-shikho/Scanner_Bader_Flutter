import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/network/final_partner_scanner_api_inventory.dart';
import 'package:scanner_partner/app/network/scanner_partner_endpoints.dart';
import 'package:scanner_partner/core/config/app_config.dart';
import 'package:scanner_partner/core/network/api_error.dart';
import 'package:scanner_partner/core/network/api_headers.dart';
import 'package:scanner_partner/core/network/api_response.dart';
import 'package:scanner_partner/core/network/api_transport.dart';

void main() {
  test('final machine inventory accounts for 31 Partner, 25 Scanner, 8 Shared APIs', () {
    expect(FinalPartnerScannerApiInventory.partnerCount, 31);
    expect(FinalPartnerScannerApiInventory.scannerCount, 25);
    expect(FinalPartnerScannerApiInventory.sharedCount, 8);
    expect(FinalPartnerScannerApiInventory.endpoints.length, 64);
    expect(
      FinalPartnerScannerApiInventory.endpoints.map((e) => e.apiId).toSet().length,
      64,
    );
    expect(ScannerPartnerEndpoints.scannerQrVerify, '/api/v1/scanner/qr/verify');
    expect(
      ScannerPartnerEndpoints.partnerOfferDisable('offer/id'),
      '/api/v1/partner/me/offers/offer%2Fid/disable',
    );
  });

  test('physical transport header identity remains partner', () {
    const context = ApiRequestHeaderContext(
      authorizationToken: 'secret-access-token',
      acceptLanguage: 'ar',
      requestId: 'request-id',
      devicePublicId: 'device-id',
      idempotencyKey: 'idem-key',
      contentType: 'application/json',
      endpointHeaders: <String, String>{'X-Endpoint-Header': 'value'},
    );

    final headers = context.build();
    expect(headers[ApiHeaderNames.authorization], 'Bearer secret-access-token');
    expect(headers[ApiHeaderNames.acceptLanguage], 'ar');
    expect(headers[ApiHeaderNames.requestId], 'request-id');
    expect(headers[ApiHeaderNames.appType], AppConfig.appType);
    expect(headers[ApiHeaderNames.appType], 'partner');
    expect(headers[ApiHeaderNames.appVersion], AppConfig.appVersion);
    expect(headers[ApiHeaderNames.platform], isNotEmpty);
    expect(headers[ApiHeaderNames.devicePublicId], 'device-id');
    expect(headers[ApiHeaderNames.timezone], AppConfig.timezone);
    expect(headers[ApiHeaderNames.idempotencyKey], 'idem-key');
    expect(headers['X-Endpoint-Header'], 'value');
  });

  test('ApiResponse preserves headers for repository-level processing', () {
    final response = ApiResponse<String>(
      data: 'decoded',
      statusCode: 429,
      headers: const <String, String>{
        'X-Request-ID': 'request-id',
        'ETag': '"v7"',
        'Retry-After': '30',
        'X-RateLimit-Limit': '60',
        'X-RateLimit-Remaining': '0',
        'X-RateLimit-Reset': '2030-01-01T00:00:00Z',
      },
    );

    expect(response.data, 'decoded');
    expect(response.requestId, 'request-id');
    expect(response.etag, '"v7"');
    expect(response.retryAfter, '30');
    expect(response.rateLimit.limit, '60');
    expect(response.rateLimit.remaining, '0');
    expect(response.rateLimit.reset, '2030-01-01T00:00:00Z');
  });

  test('normalized API error preserves translated error and headers', () {
    final error = NormalizedApiError.fromResponse(
      statusCode: 422,
      headers: const <String, String>{
        'X-Request-ID': 'request-id',
        'Retry-After': '15',
      },
      decodedBody: <String, dynamic>{
        'success': false,
        'message': <String, dynamic>{'ar': 'تعذر تنفيذ العملية', 'en': 'Failed'},
        'errors': <Object?>[
          <String, dynamic>{
            'code': 'VALIDATION_FAILED',
            'field': 'name',
            'message': <String, dynamic>{'ar': 'غير صالح', 'en': 'Invalid'},
          },
        ],
      },
    );
    expect(error.requestId, 'request-id');
    expect(error.errors.single.code, 'VALIDATION_FAILED');
    expect(error.errors.single.field, 'name');
    expect(error.retryAfter, '15');
  });

  test('ApiRequest diagnostics never stringify headers or body', () {
    const request = ApiRequest(
      method: 'POST',
      path: '/api/v1/scanner/qr/verify',
      headers: <String, String>{'Authorization': 'Bearer top-secret-token'},
      body: <String, dynamic>{
        'signed_qr_token': 'signed-secret',
        'scanner_challenge': 'challenge-secret',
        'static_qr_pin': '123456',
      },
    );
    final diagnostics = request.toString();
    expect(diagnostics, isNot(contains('top-secret-token')));
    expect(diagnostics, isNot(contains('signed-secret')));
    expect(diagnostics, isNot(contains('challenge-secret')));
    expect(diagnostics, isNot(contains('123456')));
  });
}
