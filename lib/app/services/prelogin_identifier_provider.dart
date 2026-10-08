import 'scanner_partner_repository.dart';

class PartnerPreLoginIdentifiers {
  const PartnerPreLoginIdentifiers({required this.partnerPublicId, required this.devicePublicId});
  final String partnerPublicId;
  final String devicePublicId;
}

class ScannerPreLoginIdentifiers {
  const ScannerPreLoginIdentifiers({required this.scannerDevicePublicId, required this.branchPublicId});
  final String scannerDevicePublicId;
  final String branchPublicId;
}

abstract interface class PreLoginIdentifierProvider {
  Future<PartnerPreLoginIdentifiers> partnerIdentifiers();
  Future<ScannerPreLoginIdentifiers> scannerIdentifiers();
}

/// The final handoff requires these identifiers but supplies no provisioning,
/// discovery, enrollment, deep-link, QR-enrollment, or storage-seeding contract.
/// Production therefore fails closed rather than hardcoding or asking the user
/// to type opaque production UUIDs without a documented product flow.
class UnconfiguredPreLoginIdentifierProvider implements PreLoginIdentifierProvider {
  const UnconfiguredPreLoginIdentifierProvider();
  static const blocker = 'BLOCKED_BY_MISSING_PRELOGIN_IDENTIFIER_PROVISIONING_CONTRACT';
  @override Future<PartnerPreLoginIdentifiers> partnerIdentifiers() async => throw const ScannerContractGapException(blocker);
  @override Future<ScannerPreLoginIdentifiers> scannerIdentifiers() async => throw const ScannerContractGapException(blocker);
}
