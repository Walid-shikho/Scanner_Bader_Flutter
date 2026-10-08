enum ScannerPrincipalType {
  user('user'),
  partnerEmployee('partner_employee');

  const ScannerPrincipalType(this.wireValue);
  final String wireValue;
}

enum ScannerPermission {
  scannerUse('scanner.use'),
  redemptionsExecute('redemptions.execute'),
  redemptionsView('redemptions.view'),
  redemptionsReverse('redemptions.reverse'),
  redemptionsStats('redemptions.stats'),
  partnerSelf('partner.self'),
  partnerRead('partner.read'),
  partnerProfileRequestChange('partner.profile.request_change'),
  partnerBranchesView('partner.branches.view'),
  partnerBranchesCreate('partner.branches.create'),
  partnerBranchesUpdate('partner.branches.update'),
  partnerMembersView('partner.members.view'),
  offersManage('offers.manage'),
  offersCreate('offers.create'),
  offersUpdate('offers.update'),
  offersActivate('offers.activate'),
  offersDisable('offers.disable');

  const ScannerPermission(this.wireValue);
  final String wireValue;
}

enum ScannerSessionStatus {
  unknown,
  unauthenticated,
  authenticated,
}

/// Client-side session shape only. It does not decide authorization.
///
/// Authentication/token acquisition is provided by the external canonical
/// Partner/Scanner auth handoff. Authorization permissions remain server-side
/// authoritative; this state must only contain permissions supplied by a
/// verified auth/session contract and must never infer them from role names.
class ScannerSessionState {
  const ScannerSessionState({
    required this.status,
    this.principal,
    this.principalPublicId,
    this.permissions = const <ScannerPermission>{},
  });

  const ScannerSessionState.unknown()
      : status = ScannerSessionStatus.unknown,
        principal = null,
        principalPublicId = null,
        permissions = const <ScannerPermission>{};

  const ScannerSessionState.unauthenticated()
      : status = ScannerSessionStatus.unauthenticated,
        principal = null,
        principalPublicId = null,
        permissions = const <ScannerPermission>{};

  final ScannerSessionStatus status;
  final ScannerPrincipalType? principal;
  final String? principalPublicId;
  final Set<ScannerPermission> permissions;
}
