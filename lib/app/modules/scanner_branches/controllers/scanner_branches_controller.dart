import '../../foundation/scanner_foundation_controller.dart';
import '../../../services/scanner_repository.dart';

class ScannerBranchesController extends ScannerFoundationController {
  ScannerBranchesController(ScannerRepository repository)
      : super(
          repository,
          titleKey: 'scanner_branches',
          messageKey: 'phase3_scanner_branches_message',
        );
}
