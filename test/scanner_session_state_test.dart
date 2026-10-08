import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/security/scanner_route_requirements.dart';
import 'package:scanner_partner/app/security/scanner_session_state.dart';
import 'package:scanner_partner/app/routes/app_routes.dart';

void main() {
  test('principal wire values match the final contract', () {
    expect(ScannerPrincipalType.user.wireValue, 'user');
    expect(ScannerPrincipalType.partnerEmployee.wireValue, 'partner_employee');
  });

  test('scanner route requirements preserve redemption security metadata', () {
    final reversal = ScannerRouteRequirements.byRoute[AppRoutes.redemptionReverse]!;
    final scan = ScannerRouteRequirements.byRoute[AppRoutes.qrChallenge]!;
    expect(reversal.permission, ScannerPermission.redemptionsReverse);
    expect(reversal.stepUpRequired, isTrue);
    expect(reversal.registeredScannerRequired, isTrue);
    expect(scan.permission, ScannerPermission.scannerUse);
    expect(scan.registeredScannerRequired, isTrue);
  });
}
