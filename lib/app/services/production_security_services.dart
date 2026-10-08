import 'scanner_partner_repository.dart';

/// The final handoff contains a security-only contract conflict that cannot be
/// silently reconciled:
/// - Device key registration is documented once as
///   {algorithm, public_key_pem, replace_key_public_id}
/// - and later as {public_key, key_algorithm}.
/// The machine inventory supplies only the schema name, not the field set.
/// It also uses semantic security API IDs while the prose section labels the
/// same paths with numeric API IDs. Production request execution therefore
/// fails closed until the backend contract is clarified.
abstract final class ProductionSecurityGaps {
  static const securityRequestSchemaConflict =
      'BLOCKED_BY_MISSING_SECURITY_REQUEST_SCHEMA_CONTRACT';
  static const nativeAttestationProvider =
      'BLOCKED_BY_EXTERNAL_ATTESTATION_PROVIDER';
  static const secureEs256KeyProvider =
      'BLOCKED_BY_EXTERNAL_SECURE_ES256_KEY_PROVIDER';
  static const routeNameCanonicalization =
      'BLOCKED_BY_MISSING_DEVICE_SIGNATURE_ROUTE_NAME_CONTRACT';
}

abstract interface class SensitiveRequestSecurityProvider {
  Future<Map<String, String>> headersFor({
    required String method,
    required String path,
    required Object? body,
  });

  bool get productionReady;
  String? get productionBlocker;
}

class FailClosedSensitiveRequestSecurityProvider
    implements SensitiveRequestSecurityProvider {
  const FailClosedSensitiveRequestSecurityProvider();

  @override
  bool get productionReady => false;

  @override
  String? get productionBlocker =>
      ProductionSecurityGaps.securityRequestSchemaConflict;

  @override
  Future<Map<String, String>> headersFor({
    required String method,
    required String path,
    required Object? body,
  }) {
    throw const ScannerContractGapException(
      ProductionSecurityGaps.securityRequestSchemaConflict,
    );
  }
}

/// Platform adapter boundary for Play Integrity / Apple App Attest.
/// No development bypass is permitted in production injection.
abstract interface class NativeAppAttestationProvider {
  Future<String> googlePlayIntegrityToken({
    required String nonce,
    required String purpose,
  });

  Future<Map<String, String>> appleRegister({
    required String nonce,
    required String purpose,
  });

  Future<Map<String, String>> appleAssert({
    required String nonce,
    required String purpose,
  });
}

class UnavailableNativeAppAttestationProvider
    implements NativeAppAttestationProvider {
  const UnavailableNativeAppAttestationProvider();

  Never _blocked() => throw const ScannerContractGapException(
        ProductionSecurityGaps.nativeAttestationProvider,
      );

  @override
  Future<Map<String, String>> appleAssert({
    required String nonce,
    required String purpose,
  }) async => _blocked();

  @override
  Future<Map<String, String>> appleRegister({
    required String nonce,
    required String purpose,
  }) async => _blocked();

  @override
  Future<String> googlePlayIntegrityToken({
    required String nonce,
    required String purpose,
  }) async => _blocked();
}

/// Platform-secure ES256 key boundary. The private key must never be exported
/// into Dart preferences/storage. A concrete Android Keystore / iOS Keychain
/// implementation can satisfy this interface without changing repositories.
abstract interface class DeviceRequestKeyProvider {
  Future<String> publicKeyPem();
  Future<String> signCanonicalPayload(String payload);
}

class UnavailableDeviceRequestKeyProvider implements DeviceRequestKeyProvider {
  const UnavailableDeviceRequestKeyProvider();

  Never _blocked() => throw const ScannerContractGapException(
        ProductionSecurityGaps.secureEs256KeyProvider,
      );

  @override
  Future<String> publicKeyPem() async => _blocked();

  @override
  Future<String> signCanonicalPayload(String payload) async => _blocked();
}

/// Canonical payload layout documented by the backend handoff. The route-name
/// value itself is not included in the machine inventory, so callers must not
/// invent one.
String buildDeviceSignatureCanonicalPayload({
  required String method,
  required String routeName,
  required String path,
  required String sortedQueryString,
  required String timestamp,
  required String nonce,
  required String keyPublicId,
  required String principalType,
  required String subjectPublicId,
  required String sessionPublicId,
  required String requestBodySha256,
}) => <String>[
      'BADER-DEVICE-SIGNATURE-V1',
      method.toUpperCase(),
      routeName,
      path,
      sortedQueryString,
      timestamp,
      nonce,
      keyPublicId,
      principalType,
      subjectPublicId,
      sessionPublicId,
      requestBodySha256,
    ].join('\n');
