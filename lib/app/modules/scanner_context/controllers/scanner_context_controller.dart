import '../../foundation/scanner_foundation_controller.dart';
import '../../../services/scanner_repository.dart';

class ScannerContextController extends ScannerFoundationController {
  ScannerContextController(ScannerRepository repository)
      : super(
          repository,
          titleKey: 'scanner_context',
          messageKey: 'phase3_scanner_context_message',
        );
}
