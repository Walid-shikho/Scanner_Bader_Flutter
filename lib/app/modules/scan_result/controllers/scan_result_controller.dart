import '../../foundation/scanner_foundation_controller.dart';
import '../../../services/scanner_repository.dart';

class ScanResultController extends ScannerFoundationController {
  ScanResultController(ScannerRepository repository)
      : super(
          repository,
          titleKey: 'scan_result',
          messageKey: 'phase3_scan_result_message',
        );
}
