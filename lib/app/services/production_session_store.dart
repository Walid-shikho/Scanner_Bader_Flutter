import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Only backend-authenticated logical realms are stored here.
enum ProductionSessionRealm { partner, scanner }

class ProductionSessionSnapshot {
  const ProductionSessionSnapshot({
    required this.realm,
    this.accessToken,
    this.refreshToken,
    this.sessionPublicId,
    this.devicePublicId,
    this.scannerDevicePublicId,
    this.selectedBranchPublicId,
    this.partnerProfileCache,
  });

  final ProductionSessionRealm realm;
  final String? accessToken;
  final String? refreshToken;
  final String? sessionPublicId;
  final String? devicePublicId;
  final String? scannerDevicePublicId;
  final String? selectedBranchPublicId;
  final String? partnerProfileCache;

  bool get hasAccessToken => accessToken != null && accessToken!.isNotEmpty;
  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;
  bool get hasUsableCredentials => hasAccessToken || hasRefreshToken;
}

abstract interface class ProductionSessionStore {
  Future<ProductionSessionSnapshot> read(ProductionSessionRealm realm);
  Future<void> write({
    required ProductionSessionRealm realm,
    required String accessToken,
    required String refreshToken,
    String? sessionPublicId,
    String? devicePublicId,
    String? scannerDevicePublicId,
    String? selectedBranchPublicId,
    String? partnerProfileCache,
  });
  Future<void> writeSelectedBranch(String? branchPublicId);
  Future<void> writePartnerProfileCache(String? json);
  Future<void> clear(ProductionSessionRealm realm);
  Future<void> clearAllAuthentication();
}

class SecureProductionSessionStore implements ProductionSessionStore {
  SecureProductionSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _prefix(ProductionSessionRealm realm) =>
      realm == ProductionSessionRealm.partner ? 'partner' : 'scanner';
  String _key(ProductionSessionRealm realm, String field) =>
      '${_prefix(realm)}_$field';

  @override
  Future<ProductionSessionSnapshot> read(ProductionSessionRealm realm) async {
    return ProductionSessionSnapshot(
      realm: realm,
      accessToken: await _storage.read(key: _key(realm, 'access_token')),
      refreshToken: await _storage.read(key: _key(realm, 'refresh_token')),
      sessionPublicId: await _storage.read(key: _key(realm, 'session_id')),
      devicePublicId: await _storage.read(key: _key(realm, 'device_public_id')),
      scannerDevicePublicId:
          await _storage.read(key: _key(realm, 'device_public_id')),
      selectedBranchPublicId: realm == ProductionSessionRealm.scanner
          ? await _storage.read(key: 'scanner_selected_branch_id')
          : null,
      partnerProfileCache: realm == ProductionSessionRealm.partner
          ? await _storage.read(key: 'partner_profile_cache')
          : null,
    );
  }

  @override
  Future<void> write({
    required ProductionSessionRealm realm,
    required String accessToken,
    required String refreshToken,
    String? sessionPublicId,
    String? devicePublicId,
    String? scannerDevicePublicId,
    String? selectedBranchPublicId,
    String? partnerProfileCache,
  }) async {
    // The gateway serializes session replacement with a realm-specific mutex.
    // Both rotated tokens are written in the same critical section and the old
    // refresh token is never reused after this call returns.
    await _storage.write(key: _key(realm, 'access_token'), value: accessToken);
    await _storage.write(key: _key(realm, 'refresh_token'), value: refreshToken);
    await _writeNullable(_key(realm, 'session_id'), sessionPublicId);
    final effectiveDeviceId = realm == ProductionSessionRealm.scanner
        ? scannerDevicePublicId ?? devicePublicId
        : devicePublicId;
    await _writeNullable(_key(realm, 'device_public_id'), effectiveDeviceId);
    if (realm == ProductionSessionRealm.scanner) {
      await _writeNullable('scanner_selected_branch_id', selectedBranchPublicId);
    } else {
      await _writeNullable('partner_profile_cache', partnerProfileCache);
    }
  }

  @override
  Future<void> writeSelectedBranch(String? branchPublicId) =>
      _writeNullable('scanner_selected_branch_id', branchPublicId);

  @override
  Future<void> writePartnerProfileCache(String? json) =>
      _writeNullable('partner_profile_cache', json);

  Future<void> _writeNullable(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  @override
  Future<void> clear(ProductionSessionRealm realm) async {
    for (final field in <String>[
      'access_token',
      'refresh_token',
      'session_id',
      'device_public_id',
    ]) {
      await _storage.delete(key: _key(realm, field));
    }
    if (realm == ProductionSessionRealm.scanner) {
      await _storage.delete(key: 'scanner_selected_branch_id');
    } else {
      await _storage.delete(key: 'partner_profile_cache');
    }
  }

  @override
  Future<void> clearAllAuthentication() async {
    for (final realm in ProductionSessionRealm.values) {
      await clear(realm);
    }
  }
}
