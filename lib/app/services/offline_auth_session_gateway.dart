import 'package:shared_preferences/shared_preferences.dart';

import '../auth/app_mode.dart';
import '../auth/app_mode_store.dart';
import '../security/scanner_session_state.dart';
import 'production_session_store.dart';
import 'scanner_auth_session_gateway.dart';

/// Deliberately local authentication for the Offline Demo environment.
/// It makes no security claim and never creates production tokens/sessions.
class OfflineAuthSessionGateway implements ScannerAuthSessionGateway {
  @override
  ScannerSessionState get current => const ScannerSessionState(
        status: ScannerSessionStatus.authenticated,
        principal: ScannerPrincipalType.partnerEmployee,
        principalPublicId: 'offline-demo-user',
        permissions: <ScannerPermission>{
          ScannerPermission.scannerUse,
          ScannerPermission.redemptionsExecute,
          ScannerPermission.redemptionsView,
          ScannerPermission.redemptionsReverse,
          ScannerPermission.redemptionsStats,
        },
      );

  OfflineAuthSessionGateway(this.modeStore);

  final AppModeStore modeStore;

  static const _partnerLoggedInKey = 'offline_partner_logged_in';
  static const _scannerLoggedInKey = 'offline_scanner_logged_in';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  String _key(AppMode mode) =>
      mode == AppMode.partner ? _partnerLoggedInKey : _scannerLoggedInKey;

  Future<bool> isLoggedIn(AppMode mode) async =>
      (await _preferences).getBool(_key(mode)) ?? false;

  Future<void> loginOffline({
    required AppMode mode,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw const FormatException('offline_demo_email_invalid');
    }
    if (password.trim().isEmpty) {
      throw const FormatException('offline_demo_password_required');
    }
    final preferences = await _preferences;
    await preferences.setBool(_key(mode), true);
    await modeStore.writeActiveMode(mode);
  }

  @override
  Future<AppMode?> init() async {
    final active = await modeStore.readActiveMode();
    if (active == null || !await isLoggedIn(active)) return null;
    return active;
  }

  @override
  Future<bool> restoreMode(AppMode mode) async {
    if (!await isLoggedIn(mode)) return false;
    await modeStore.writeActiveMode(mode);
    return true;
  }

  @override
  Future<void> loginPartner(PartnerLoginRequest request) => loginOffline(
        mode: AppMode.partner,
        email: request.email,
        password: request.password,
      );

  @override
  Future<void> loginScanner(ScannerLoginRequest request) => loginOffline(
        mode: AppMode.scanner,
        email: request.email,
        password: request.password,
      );

  @override
  Future<void> refresh(ProductionSessionRealm realm) async {
    // Offline Demo intentionally has no refresh-token lifecycle.
  }

  @override
  Future<void> logout(ProductionSessionRealm realm) async {
    final mode = realm == ProductionSessionRealm.partner
        ? AppMode.partner
        : AppMode.scanner;
    final preferences = await _preferences;
    await preferences.setBool(_key(mode), false);
    if (await modeStore.readActiveMode() == mode) {
      await modeStore.clearActiveMode();
    }
  }

  @override
  Future<void> logoutAllPartnerSessions() async {
    final preferences = await _preferences;
    await preferences.setBool(_partnerLoggedInKey, false);
    if (await modeStore.readActiveMode() == AppMode.partner) {
      await modeStore.clearActiveMode();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> listPartnerSessions() async =>
      await isLoggedIn(AppMode.partner)
          ? <Map<String, dynamic>>[
              <String, dynamic>{
                'public_id': 'offline-partner-session',
                'app_type': 'partner',
                'status': 'active',
                'current': true,
              },
            ]
          : const <Map<String, dynamic>>[];

  @override
  Future<void> revokePartnerSession(String sessionPublicId) =>
      logout(ProductionSessionRealm.partner);

  @override
  Future<void> switchMode(AppMode mode) async {
    if (!await restoreMode(mode)) {
      throw StateError('offline_demo_destination_login_required');
    }
  }
}
