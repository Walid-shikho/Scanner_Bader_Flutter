import 'dart:async';
import 'dart:convert';

import '../../core/config/app_config.dart';
import '../../core/network/api_error.dart';
import '../../core/network/api_headers.dart';
import '../../core/network/api_transport.dart';
import '../../core/network/request_id_factory.dart';
import '../auth/app_mode.dart';
import '../auth/app_mode_store.dart';
import '../security/scanner_session_state.dart';
import 'production_session_store.dart';

class ScannerLoginRequest {
  const ScannerLoginRequest({
    required this.email,
    required this.password,
    required this.scannerDevicePublicId,
    required this.branchPublicId,
  });
  final String email;
  final String password;
  final String scannerDevicePublicId;
  final String branchPublicId;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'password': password,
        'scanner_device_public_id': scannerDevicePublicId,
        'branch_public_id': branchPublicId,
      };
}

class PartnerLoginRequest {
  const PartnerLoginRequest({
    required this.email,
    required this.password,
    required this.partnerPublicId,
    required this.devicePublicId,
  });
  final String email;
  final String password;
  final String partnerPublicId;
  final String devicePublicId;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'password': password,
        'partner_public_id': partnerPublicId,
        'device_public_id': devicePublicId,
      };
}

class AuthTokenPair {
  const AuthTokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.appType,
    this.sessionPublicId,
    this.devicePublicId,
  });

  factory AuthTokenPair.fromEnvelope(Object? value) {
    final envelope = Map<String, dynamic>.from(value as Map);
    final data = Map<String, dynamic>.from(envelope['data'] as Map);
    final session = data['session'] is Map
        ? Map<String, dynamic>.from(data['session'] as Map)
        : const <String, dynamic>{};
    final device = data['device'] is Map
        ? Map<String, dynamic>.from(data['device'] as Map)
        : const <String, dynamic>{};
    return AuthTokenPair(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      appType: (session['app_type'] ?? _jwtAppCode(data['access_token'] as String))
          as String?,
      sessionPublicId: session['public_id'] as String?,
      devicePublicId:
          device['public_id'] as String? ?? session['device_public_id'] as String?,
    );
  }

  final String accessToken;
  final String refreshToken;
  final String? appType;
  final String? sessionPublicId;
  final String? devicePublicId;

  static String? _jwtAppCode(String token) => _decodeJwtPayload(token)?['app_code'] as String?;
}

Map<String, dynamic>? _decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    final normalized = base64Url.normalize(parts[1]);
    return Map<String, dynamic>.from(
      jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map,
    );
  } catch (_) {
    return null;
  }
}

bool _tokenExpired(String token, {Duration skew = const Duration(seconds: 30)}) {
  final exp = _decodeJwtPayload(token)?['exp'];
  if (exp is! num) return false;
  final expires = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
  return !expires.isAfter(DateTime.now().toUtc().add(skew));
}

abstract interface class ScannerAuthSessionGateway {
  ScannerSessionState get current;
  Future<AppMode?> init();
  Future<bool> restoreMode(AppMode mode);
  Future<void> loginScanner(ScannerLoginRequest request);
  Future<void> loginPartner(PartnerLoginRequest request);
  Future<void> refresh(ProductionSessionRealm realm);
  Future<void> logout(ProductionSessionRealm realm);
  Future<void> logoutAllPartnerSessions();
  Future<List<Map<String, dynamic>>> listPartnerSessions();
  Future<void> revokePartnerSession(String sessionPublicId);
  Future<void> switchMode(AppMode mode);
}

class ApiScannerAuthSessionGateway implements ScannerAuthSessionGateway {
  @override
  ScannerSessionState get current => const ScannerSessionState.unknown();

  ApiScannerAuthSessionGateway({
    required this.transport,
    required this.store,
    required this.modeStore,
    required this.requestIds,
    required this.acceptLanguage,
  });

  final ApiTransport transport;
  final ProductionSessionStore store;
  final AppModeStore modeStore;
  final RequestIdFactory requestIds;
  final String Function() acceptLanguage;
  final Map<ProductionSessionRealm, Future<void>?> _refreshInFlight = {
    ProductionSessionRealm.partner: null,
    ProductionSessionRealm.scanner: null,
  };

  Map<String, String> _publicHeaders() => <String, String>{
        ApiHeaderNames.accept: 'application/json',
        ApiHeaderNames.acceptLanguage: acceptLanguage(),
        ApiHeaderNames.contentType: 'application/json',
        ApiHeaderNames.requestId: requestIds.create(),
        ApiHeaderNames.appType: AppConfig.appType,
        ApiHeaderNames.appVersion: AppConfig.appVersion,
        ApiHeaderNames.platform: AppConfig.platform,
        ApiHeaderNames.timezone: AppConfig.timezone,
      };

  Map<String, String> _authHeaders(String token) => <String, String>{
        ..._publicHeaders(),
        ApiHeaderNames.authorization: 'Bearer $token',
      };

  ProductionSessionRealm _realm(AppMode mode) => mode == AppMode.partner
      ? ProductionSessionRealm.partner
      : ProductionSessionRealm.scanner;

  @override
  Future<AppMode?> init() async {
    final active = await modeStore.readActiveMode();
    if (active == null) return null;
    return await restoreMode(active) ? active : null;
  }

  @override
  Future<bool> restoreMode(AppMode mode) async {
    final realm = _realm(mode);
    final snapshot = await store.read(realm);
    if (!snapshot.hasUsableCredentials) return false;
    try {
      if (!snapshot.hasAccessToken || _tokenExpired(snapshot.accessToken!)) {
        await refresh(realm);
      } else {
        final claim = _decodeJwtPayload(snapshot.accessToken!)?['app_code'];
        if (claim != null && claim != mode.appCode) {
          await store.clear(realm);
          return false;
        }
      }
      await modeStore.writeActiveMode(mode);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _login({
    required AppMode mode,
    required String path,
    required Map<String, dynamic> body,
    String? scannerDevicePublicId,
    String? selectedBranchPublicId,
  }) async {
    final response = await transport.send<AuthTokenPair>(
      ApiRequest(method: 'POST', path: path, headers: _publicHeaders(), body: body),
      decodeData: AuthTokenPair.fromEnvelope,
    );
    if (response.data.appType != mode.appCode) {
      throw StateError('Authentication response app_type mismatch for ${mode.appCode}.');
    }
    await store.write(
      realm: _realm(mode),
      accessToken: response.data.accessToken,
      refreshToken: response.data.refreshToken,
      sessionPublicId: response.data.sessionPublicId,
      devicePublicId: response.data.devicePublicId,
      scannerDevicePublicId: scannerDevicePublicId,
      selectedBranchPublicId: selectedBranchPublicId,
    );
    await modeStore.writeActiveMode(mode);
  }

  @override
  Future<void> loginScanner(ScannerLoginRequest request) => _login(
        mode: AppMode.scanner,
        path: '/api/v1/auth/scanner/login',
        body: request.toJson(),
        scannerDevicePublicId: request.scannerDevicePublicId,
        selectedBranchPublicId: request.branchPublicId,
      );

  @override
  Future<void> loginPartner(PartnerLoginRequest request) => _login(
        mode: AppMode.partner,
        path: '/api/v1/auth/partner/login',
        body: request.toJson(),
      );

  @override
  Future<void> refresh(ProductionSessionRealm realm) {
    final existing = _refreshInFlight[realm];
    if (existing != null) return existing;
    final operation = _performRefresh(realm);
    _refreshInFlight[realm] = operation;
    return operation.whenComplete(() => _refreshInFlight[realm] = null);
  }

  Future<void> _performRefresh(ProductionSessionRealm realm) async {
    final snapshot = await store.read(realm);
    final refreshToken = snapshot.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await store.clear(realm);
      throw StateError('${realm.name} refresh token is unavailable.');
    }
    final mode = realm == ProductionSessionRealm.scanner ? AppMode.scanner : AppMode.partner;
    try {
      final response = await transport.send<AuthTokenPair>(
        ApiRequest(
          method: 'POST',
          path: '/api/v1/auth/${mode.appCode}/refresh',
          headers: _publicHeaders(),
          body: <String, dynamic>{'refresh_token': refreshToken},
        ),
        decodeData: AuthTokenPair.fromEnvelope,
      );
      if (response.data.appType != mode.appCode) {
        throw StateError('Refresh response app_type mismatch.');
      }
      await store.write(
        realm: realm,
        accessToken: response.data.accessToken,
        refreshToken: response.data.refreshToken,
        sessionPublicId: response.data.sessionPublicId ?? snapshot.sessionPublicId,
        devicePublicId: response.data.devicePublicId ?? snapshot.devicePublicId,
        scannerDevicePublicId: snapshot.scannerDevicePublicId,
        selectedBranchPublicId: snapshot.selectedBranchPublicId,
        partnerProfileCache: snapshot.partnerProfileCache,
      );
    } on NormalizedApiError catch (error) {
      if (error.statusCode == 401) {
        await store.clear(realm);
        final active = await modeStore.readActiveMode();
        if (active != null && _realm(active) == realm) {
          await modeStore.clearActiveMode();
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> logout(ProductionSessionRealm realm) async {
    final snapshot = await store.read(realm);
    final mode = realm == ProductionSessionRealm.scanner ? AppMode.scanner : AppMode.partner;
    try {
      if (snapshot.hasAccessToken) {
        await transport.send<Object?>(
          ApiRequest(
            method: 'POST',
            path: '/api/v1/auth/${mode.appCode}/logout',
            headers: _authHeaders(snapshot.accessToken!),
            body: const <String, dynamic>{},
          ),
          decodeData: (_) => null,
        );
      }
    } finally {
      await store.clear(realm);
      final active = await modeStore.readActiveMode();
      if (active != null && _realm(active) == realm) {
        await modeStore.clearActiveMode();
      }
    }
  }

  @override
  Future<void> logoutAllPartnerSessions() async {
    final snapshot = await store.read(ProductionSessionRealm.partner);
    if (!snapshot.hasAccessToken) return;
    try {
      await transport.send<Object?>(
        ApiRequest(
          method: 'POST',
          path: '/api/v1/auth/partner/logout-all',
          headers: _authHeaders(snapshot.accessToken!),
          body: const <String, dynamic>{},
        ),
        decodeData: (_) => null,
      );
    } finally {
      await store.clear(ProductionSessionRealm.partner);
      final active = await modeStore.readActiveMode();
      if (active == AppMode.partner) await modeStore.clearActiveMode();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> listPartnerSessions() async {
    final snapshot = await store.read(ProductionSessionRealm.partner);
    if (!snapshot.hasAccessToken) throw StateError('Partner session required.');
    final response = await transport.send<List<Map<String, dynamic>>>(
      ApiRequest(
        method: 'GET',
        path: '/api/v1/auth/partner/sessions',
        headers: _authHeaders(snapshot.accessToken!),
      ),
      decodeData: (value) {
        final envelope = Map<String, dynamic>.from(value as Map);
        final data = envelope['data'];
        final list = data is List ? data : (data is Map ? data['items'] as List? : null);
        return (list ?? const <dynamic>[])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(growable: false);
      },
    );
    return response.data;
  }

  @override
  Future<void> revokePartnerSession(String sessionPublicId) async {
    final snapshot = await store.read(ProductionSessionRealm.partner);
    if (!snapshot.hasAccessToken) throw StateError('Partner session required.');
    await transport.send<Object?>(
      ApiRequest(
        method: 'DELETE',
        path: '/api/v1/auth/partner/sessions/${Uri.encodeComponent(sessionPublicId)}',
        headers: _authHeaders(snapshot.accessToken!),
      ),
      decodeData: (_) => null,
    );
  }

  @override
  Future<void> switchMode(AppMode mode) async {
    if (!await restoreMode(mode)) {
      throw StateError('No valid stored ${mode.appCode} session.');
    }
  }
}
