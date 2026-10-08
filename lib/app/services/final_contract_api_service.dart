import '../../core/network/api_headers.dart';
import '../../core/network/api_transport.dart';
import '../../core/network/request_id_factory.dart';
import '../auth/app_mode.dart';
import '../network/final_partner_scanner_api_inventory.dart';
import 'idempotency_key_factory.dart';
import 'production_security_services.dart';
import 'production_session_store.dart';
import 'scanner_auth_session_gateway.dart';

/// Generic contract executor used for final-contract endpoints that do not
/// require a dedicated UI/domain model. It enforces mode-scoped bearer tokens
/// from endpoint metadata, never from the currently visible widget.
class FinalContractApiService {
  FinalContractApiService({
    required this.transport,
    required this.sessions,
    required this.auth,
    required this.requestIds,
    required this.acceptLanguage,
    required this.security,
    required this.idempotency,
  });

  final ApiTransport transport;
  final ProductionSessionStore sessions;
  final ScannerAuthSessionGateway auth;
  final RequestIdFactory requestIds;
  final String Function() acceptLanguage;
  final SensitiveRequestSecurityProvider security;
  final IdempotencyKeyFactory idempotency;

  ProductionSessionRealm _realm(ContractMode mode) {
    switch (mode) {
      case ContractMode.partner:
        return ProductionSessionRealm.partner;
      case ContractMode.scanner:
        return ProductionSessionRealm.scanner;
      case ContractMode.shared:
        throw StateError('Shared endpoints do not have an authenticated realm.');
    }
  }

  Future<Map<String, String>> _headers(
    FinalApiEndpoint endpoint, {
    Object? body,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      ApiHeaderNames.accept: 'application/json',
      ApiHeaderNames.acceptLanguage: acceptLanguage(),
      ApiHeaderNames.requestId: requestIds.create(),
      if (endpoint.method != 'GET') ApiHeaderNames.contentType: 'application/json',
    };
    if (endpoint.auth) {
      final snapshot = await sessions.read(_realm(endpoint.mode));
      if (!snapshot.hasAccessToken) {
        throw StateError('${endpoint.mode.name} session required for ${endpoint.apiId}.');
      }
      headers[ApiHeaderNames.authorization] = 'Bearer ${snapshot.accessToken}';
    }
    if (endpoint.idempotencyRequired) {
      if (idempotencyKey == null || idempotencyKey.isEmpty) {
        throw ArgumentError('Idempotency key is required for ${endpoint.apiId}.');
      }
      headers[ApiHeaderNames.idempotencyKey] = idempotencyKey;
    }
    if (endpoint.deviceSignature != 'none') {
      headers.addAll(await security.headersFor(
        method: endpoint.method,
        path: endpoint.path,
        body: body,
      ));
    }
    return headers;
  }

  Future<Object?> execute({
    required String apiId,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> query = const <String, String>{},
    Object? body,
    String? idempotencyKey,
  }) async {
    final endpoint = FinalPartnerScannerApiInventory.byId(apiId);
    var path = endpoint.path;
    for (final entry in pathParameters.entries) {
      path = path.replaceAll('{${entry.key}}', Uri.encodeComponent(entry.value));
    }
    if (path.contains('{')) {
      throw ArgumentError('Missing path parameter for ${endpoint.apiId}.');
    }

    Future<Object?> attempt() async {
      final response = await transport.send<Object?>(
        ApiRequest(
          method: endpoint.method,
          path: path,
          queryParameters: query,
          headers: await _headers(endpoint, body: body, idempotencyKey: idempotencyKey),
          body: body,
        ),
        decodeData: (value) {
          if (value is Map && value['data'] != null) return value['data'];
          return value;
        },
      );
      return response.data;
    }

    try {
      return await attempt();
    } catch (error) {
      // Dedicated repositories own rich error mapping. This generic executor
      // intentionally does not fake success or replace backend failures.
      rethrow;
    }
  }

  String newOperationIdempotencyKey() => idempotency.create();

  Future<void> switchMode(AppMode mode) => auth.switchMode(mode);
}
